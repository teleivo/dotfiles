# JAVA DEVELOPMENT ENVIRONMENT

using https://github.com/mfussenegger/nvim-jdtls with the Java LSP
https://github.com/eclipse/eclipse.jdt.ls

## Setup

* install nvim-jdtls plugin
* install Java LSP

Build

```sh
./mvnw clean verify -DskipTests
```

Then try to run it https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line

### Lombok

```sh
sudo mkdir ~/.local/share/lombok
sudo wget https://projectlombok.org/downloads/lombok.jar -O / ~/.local/share/lombok/lombok.jar
```
