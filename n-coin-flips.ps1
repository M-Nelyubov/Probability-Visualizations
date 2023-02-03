param($n=15)
Import-Module PSGraph

$fileName = (Split-Path $PSCommandPath -Leaf).Replace(".ps1","")

class Connection {
    [string] $start
    [string] $end
    [string] $label
    [int]    $odds
    [bool]   $oddsEnabled
    
    Connection ($start, $end, $label="") {
        $this.start = $start
        $this.end   = $end
        $this.label = $label
        $this.odds  = 1
        $this.oddsEnabled = $true
    }

    Connection ($start, $end, $label="", $odds) {
        $this.start = $start
        $this.end   = $end
        $this.label = $label
        $this.odds  = $odds
        $this.oddsEnabled = $true
    }
}

$edges = @()


$startText = "Start"

[string[]]$latestWave = @($startText)



1..$n | foreach {
    $latestWave = $latestWave | foreach {
        $rootNode = $_
        @("H","T") | foreach {
            $edges += [Connection]::new($rootNode, "$rootNode,$_", $_)
            "$rootNode,$_"
        } | where {$_[-1] -eq "H"}
    }
}

graph d -Attributes @{dpi=200; fontsize=20; compound=$true} {
    $edges | foreach {
        edge $_.start.Replace("$startText,","") $_.end.Replace("$startText,","") -Attributes @{label=$_.label}
    }
} | Export-PSGraph -ShowGraph -LayoutEngine Hierarchical -DestinationPath "$PSScriptRoot\images\$fileName-$((Get-Date).toString('yyyy-MM-dd_hh-mm_ss')).png"
