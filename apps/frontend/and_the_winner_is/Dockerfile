# FROM cirrusci/flutter:latest AS build

# WORKDIR /app

# COPY . .

# RUN flutter pub get
# RUN flutter build web

FROM ghcr.io/cirruslabs/flutter:stable AS build

# RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-8-jdk wget

# RUN git clone https://github.com/flutter/flutter.git
# ENV PATH "$PATH:/home/developer/flutter/bin"

RUN flutter doctor

WORKDIR /app

COPY . .

RUN flutter pub get
RUN flutter build web


FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
