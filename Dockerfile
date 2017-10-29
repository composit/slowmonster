FROM elixir:1.5.1

# install hex
RUN mix local.hex --force

# install phoenix 1.3
RUN curl -sL https://github.com/phoenixframework/archives/raw/master/phx_new-1.3.0.ez -o phx_new-1.3.0.ez
RUN mix archive.install ./phx_new-1.3.0.ez --force

# install node 8.x
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# install inotify for live code reloading
RUN apt-get install -y inotify-tools

# install rebar
RUN mix local.rebar --force

# get dependencies
run mix deps.get

COPY . /root/code
WORKDIR /root/code
#RUN npm install

CMD ["mix", "phx.server"]
