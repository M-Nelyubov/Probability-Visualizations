Import-Module PSGraph

$fileName = (Split-Path $PSCommandPath -Leaf).Replace(".ps1","")

class Connection {
    [string] $start
    [string] $end
    [string] $label
    
    Connection ($start, $end, $label="") {
        $this.start = $start
        $this.end   = $end
        $this.label = $label
    }
}

$edges = @()


[string[]]$latestWave = @("Start")


$latestWave = $latestWave | foreach {
    $rootNode = $_
    1..6 | foreach {
        $edges += [Connection]::new($rootNode, $_, $_)
        "$_"
    }
}

$latestWave = $latestWave | foreach {
    $rootNode = $_
    1..6 | foreach {
        $edges += [Connection]::new($rootNode, "$rootNode, $_", $_)
        "$rootNode, $_"
    }
}

$latestWave = $latestWave | foreach {
    $rootNode = $_
    @("H","T") | foreach {
        $edges += [Connection]::new($rootNode, "$rootNode, $_", $_)
        "$rootNode, $_"
    }
}


graph d -Attributes @{dpi=200; fontsize=20; compound=$true} {
    $edges | foreach {
        edge $_.start $_.end -Attributes @{label=$_.label}
    }
} | Export-PSGraph -ShowGraph -LayoutEngine Hierarchical -DestinationPath "$PSScriptRoot\images\$fileName-$((Get-Date).toString('yyyy-MM-dd_hh-mm_ss')).png"
