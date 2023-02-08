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


# Tracks how much (in terms of odds) each node emits
$sources = @{}

$edges = @()


[string[]]$latestWave = @("Start")


$latestWave = $latestWave | foreach {
    $rootNode = $_
    1..6 | foreach {
        $edges += [Connection]::new($rootNode, $_, $_)
        $sources[$rootNode] = 1 + ($sources[$rootNode])
        "$_"
    }
}

$latestWave = $latestWave | foreach {
    $rootNode = $_
    1..6 | foreach {
        $edges += [Connection]::new($rootNode, "$rootNode, $_", $_)
        $sources[$rootNode] = 1 + ($sources[$rootNode])
        "$rootNode, $_"
    }
}

$latestWave = $latestWave | foreach {
    $rootNode = $_
    @("H","T") | foreach {
        $edges += [Connection]::new($rootNode, "$rootNode, $_", $_)
        $sources[$rootNode] = 1 + ($sources[$rootNode])
        "$rootNode, $_"
    }
}


graph d -Attributes @{dpi=200; fontsize=20; compound=$true} {
    $edges | foreach {
        edge $_.start $_.end -Attributes @{label="$($_.odds)/$($sources[$_.start])"}
    }
} | Export-PSGraph -ShowGraph -LayoutEngine Hierarchical -DestinationPath "$PSScriptRoot\images\$fileName-$((Get-Date).toString('yyyy-MM-dd_hh-mm_ss')).png"
