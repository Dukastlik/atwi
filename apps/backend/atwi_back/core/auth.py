import hashlib
import hmac, json
from urllib.parse import parse_qsl
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Annotated
import requests

from core.config import settings


class UserValidator:
    '''
    Validates that request is a valid telegram request 
    and that user is in proper group
    '''

    respone_header = {"WWW-Authenticate": "Bearer"}

    def __call__(
        self,
        creds: Annotated[HTTPAuthorizationCredentials, Depends(HTTPBearer())]
    ) -> int:
        user_creds = creds.credentials
        parsed_creds = dict(parse_qsl(user_creds))
        hash_ = parsed_creds.pop('hash', None)

        # if we not in a context telegram
        # we return demo user id 123
        if not settings.IS_TELE_APP:
            return 123

        if not hash_:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
                headers=self.respone_header,
            )
        data_check_string = '\n'.join(f"{k}={v}" for k, v in sorted(parsed_creds.items()))
        hmac_hash = hmac.new(
            settings.TG_BOT_TOKEN.encode(),
            data_check_string.encode(),
            hashlib.sha256
        ).hexdigest()
        if not hmac_hash == hash_:
            HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Could not validate credentials",
                headers=self.respone_header,
            )
        user = json.loads(parsed_creds['user'])
        return user['id']

class UserGroupValidator:

    def __call__(
        self,
        user_id: Annotated[int, Depends(UserValidator())]
    ) -> int:
        # validates that user is a member of a certain tg group
        if not settings.IS_TELE_APP:
            return user_id
        resp = requests.get(
            url=settings.full_tg_groups_api_url,
            params={"chat_id": settings.TG_GROUP_ID, "user_id": user_id}
        )
        if resp.status_code != 200:
            raise HTTPException(status_code=401, detail="You are not a member!")
        return user_id


user_validator = UserGroupValidator()

UserIdDep = Annotated[str, Depends(user_validator)]
