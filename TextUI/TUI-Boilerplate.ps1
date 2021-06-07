Import-Module Microsoft.PowerShell.ConsoleGuiTools 
$module = (Get-Module Microsoft.PowerShell.ConsoleGuiTools -List).ModuleBase
Add-Type -Path (Join-path $module Terminal.Gui.dll)

# INITIALIZE TUI
[Terminal.Gui.Application]::Init()
$Window = [Terminal.Gui.Window]::new()
$Window.Title = "PoSH - TUI Example"
[Terminal.Gui.Application]::Top.Add($Window)

# FILE MENU
$FileMenuItem = [Terminal.Gui.MenuItem]::new("Exit", "", { 
  [Terminal.Gui.Application]::Shutdown() 
  Exit(0)
})
$FileMenuBarItem = [Terminal.Gui.MenuBarItem]::new("File", @($FileMenuItem))

# HELP MENU
$AboutMenuItem = [Terminal.Gui.MenuItem]::new("About", "", { [Terminal.Gui.MessageBox]::Query("About", "Simple TUI Example") })
$HelpMenuBarItem = [Terminal.Gui.MenuBarItem]::new("Help", @($AboutMenuItem))

$MenuBar = [Terminal.Gui.MenuBar]::new(@($FileMenuBarItem, $HelpMenuBarItem))

$Window.Add($MenuBar)

[Terminal.Gui.Application]::Run()
