Add-Type -AssemblyName PresentationCore, PresentationFramework

$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" Width="800" Height="500" Name="IPScan" Title="IP Scan">

<Grid>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Name="baseIPLabel" Text="First Three Octents (i.e. 192.168.2)" Margin="8,35,0,0"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Name="statusText" Text=" " Margin="200,35,0,0"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Width="180" TextWrapping="NoWrap" Margin="7,52,0,0" Name="baseIP" ToolTip="Base IP Address"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Width="180" TextWrapping="NoWrap" Margin="9,144,0,0" Name="startIP" ToolTip="Starting IP"/>
<TextBox HorizontalAlignment="Left" VerticalAlignment="Top" Height="28" Width="180" TextWrapping="NoWrap" Margin="211,144,0,0" Name="endIP" ToolTip="Ending IP"/>
<Button Content="Scan" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="695,154,0,0" Name="scanButton"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="End Range" Margin="211,125,0,0" Name="endIPLabel"/>
<TextBlock HorizontalAlignment="Left" VerticalAlignment="Top" TextWrapping="Wrap" Text="Start Range" Margin="9,125,0,0" Name="startIPLabel"/>
<DataGrid HorizontalAlignment="Left" VerticalAlignment="Top" Width="767" Height="233" Margin="9,215,0,0" Name="grid">
	<DataGrid.Columns>
		<DataGridTextColumn Header="IP" Binding="{Binding IP}" Width="SizeToCells"/>
		<DataGridTextColumn Header="Result" Binding="{Binding Result}" Width="SizeToCells"/>


	</DataGrid.Columns>
</DataGrid>
</Grid>
</Window>
"@

$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

$scanButton.Add_Click({
runPing 

})

$ping = New-Object System.Net.Networkinformation.Ping
Function runPing{


        $grid.Items.Clear()

	
	    if($baseIP.text -eq $null){
		    Write-Host "Base IP cannot be null"
            Exit
	    }else{
            $network = $baseIP.text 
        }

	    if($startIP.text -eq $null){
		    Write-Host "Starting IP cannot be null"
            Exit
	    }else{
            [int]$beginIP = $startIP.text 
        }

	    if($endIP.text -eq $null){
		    Write-Host "Ending IP cannot be null"
            Exit
	    }else{
            [int]$stopIP = $endIP.text 
        }

        For($i=$beginIP;$i -le $stopIP; $i++) { 

                $Window.Dispatcher.Invoke([Windows.Threading.DispatcherPriority]::Background, [action]{
                $ip = $network + "." + $i
                Write-Host "Pinging $ip"
                $statusText.Text = "PINGING $ip" 
                $response = $ping.Send($ip, 1000) 
                $row = New-Object -typeName PSObject
                Add-member -inputObject $row -memberType NoteProperty -Name "IP" -Value $ip
                Add-member -inputObject $row -memberType NoteProperty -Name "Result" -Value $response.status
                $statusText.Text = "Attempting to get Hostname for $ip"
  
                $grid.AddChild($row)
                })

         }  
 
    }




$Window.ShowDialog()
