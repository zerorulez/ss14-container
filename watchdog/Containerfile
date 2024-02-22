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
FROM container-registry.oracle.com/os/oraclelinux:9-slim

RUN microdnf install -y dnf; \
	dnf install -y 'dnf-command(config-manager)'; \
	rm -rf /var/cache/*

RUN dnf -y install oracle-epel-release-el9; \
	rm -rf /var/cache/*

RUN dnf install -y git libsodium dotnet-sdk-8.0 vim findutils; \
	rm -rf /var/cache/*

RUN cd /usr/lib64; ln -sf libsodium.so.*.* libsodium.so; \
	ln -sf python3 /usr/bin/python;

RUN useradd watchdog

USER watchdog

WORKDIR /home/watchdog/

#ADD config.toml /home/watchdog/instances/default/

RUN git clone --single-branch --depth 1 https://github.com/space-wizards/SS14.Watchdog build; \
	cd build; \
	dotnet publish -c Release --no-self-contained; \
	mv SS14.Watchdog/bin/Release/net8.0/publish/* ..; \
	cd ..; \
	rm -rf build ~/.nuget/ ~/.local/share/NuGet/

ADD appsettings.yml .

CMD ./SS14.Watchdog
