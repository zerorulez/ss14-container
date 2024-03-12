#    Builds an image for running SS14.Watchdog - the space-station-14 automated server builder and watchdog
#
#    Copyright (C) 2023 Raphael Bertoche
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
FROM docker.io/library/ubuntu:jammy

RUN apt update && apt install -y git libsodium-dev dotnet-sdk-8.0 vim findutils python3 && \
	rm -rf /var/cache/*

RUN sudo mkdir ss14 && chmod 777 ss14

RUN useradd watchdog

USER watchdog

WORKDIR /ss14

#ADD config.toml /home/watchdog/instances/default/

RUN git clone --single-branch --depth 1 https://github.com/space-wizards/SS14.Watchdog build; \
	cd build; \
	dotnet publish -c Release --no-self-contained; \
	mv SS14.Watchdog/bin/Release/net8.0/publish/* ..; \
	cd ..; \
	rm -rf build ~/.nuget/ ~/.local/share/NuGet/

ADD appsettings.yml .

CMD ./SS14.Watchdog
