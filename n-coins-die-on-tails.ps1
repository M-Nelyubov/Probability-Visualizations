param($n=5)
Import-Module PSGraph

$fileName = (Split-Path $PSCommandPath -Leaf).Replace(".ps1","").Replace("n-c", "$n-c")

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


$startText = " Start "

[string[]]$latestWave = @($startText)

# Tracks how much (in terms of odds) each node emits
$sources = @{}


1..$n | foreach {
    $latestWave = $latestWave | foreach {
        $rootNode = $_

        # Continue on heads
        if($rootNode[-1] -eq "H" -or $rootNode -like $startText){
            @("H","T") | foreach {
                $edges += [Connection]::new($rootNode, "$rootNode,$_", $_)
                $sources[$rootNode] = 1 + ($sources[$rootNode])
                "$rootNode,$_"
            }
        }

        # Terminate with a die roll on tails
        if($rootNode[-1] -eq "T"){
            1..6 | foreach {
                $edges += [Connection]::new($rootNode, "$rootNode,$_", $_)
                $sources[$rootNode] = 1 + ($sources[$rootNode])
            }
        }
    }
}


graph d -Attributes @{dpi=200; fontsize=20; compound=$true} {
    $edges | foreach {
        edge $_.start.Replace("$startText,","") $_.end.Replace("$startText,","") -Attributes @{label="$($_.odds)/$($sources[$_.start])"}
    }
} | Export-PSGraph -ShowGraph -LayoutEngine Hierarchical -DestinationPath "$PSScriptRoot\images\$fileName-$((Get-Date).toString('yyyy-MM-dd_hh-mm_ss')).png"
