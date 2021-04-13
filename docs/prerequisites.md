# Installing prerequisites

The following things are required on your system.

- git
- VS Code
- Azure Function Core Tools (version 3.0.3160 or higher)
- PowerShell 7
- HTTP Testing and Debugging tool like [Postman](https://www.postman.com/), [Httpmaster](https://www.httpmaster.net/) or [Insomnia](https://insomnia.rest/)


## Windows

The prerequisites on Windows can be installed using [Chocolatey](https://chocolatey.org/) (a package manager for Windows).

```
# Install Git
choco install git
# Install VSCode
choco install vscode
# Install Azure Function Core Tools
choco install azure-functions-core-tools-3
# Install PowerShell Core
choco install pwsh
# Install HttpMaster
choco install postman
```

## MacOs
The prerequisites on MacOs can be installed using [brew](https://brew.sh/) (a package manager for Mac).

```
# Install Git
brew install git
# Install VSCode
brew install --cask visual-studio-code
# Install dotnet
brew tap caskroom/caskbrew cask install dotnet
# Install Azure Function Core Tools
brew install azure-functions-core-tools@3
# Install PowerShell 7
brew install --cask powershell
# Install Postman
brew install --cask postman
```

## Install PowerShell Modules

After cloning the Git Repository you can use the bootstrap.ps1 script to install the required PowerShell modules.

![Bootstrap screenshot](/pictures/bootstrap.png)

The following PowerShell Modules need to be installed:

- InvokeBuild
- Pester
- PlatyPS
- Az PowerShell modules*

\* The installation of the Az PowerShell modules are not part of the bootstrap.ps1 script. If you have not installed these PowerShell modules run `Install-Module -Name Az`on your development machine.
