<#
.SYNOPSIS
Obtiene información de procesos, discos, archivos y conexiones de red de la máquina.
.DESCRIPTION
Despliega los cinco procesos que más CPU consumen, los discos conectados con su tamaño y espacio libre, el archivo más grande en un disco especificado, la memoria libre y el uso de swap, y el número de conexiones de red activas.
.PARAMETER ComputerName
El nombre del computador a consultar.
.PARAMETER DiskPath
La ruta del disco o filesystem para buscar el archivo más grande.
.EXAMPLE
.\Get-SystemInfo.ps1
#>

[CmdletBinding()]
param (
  [Parameter(Mandatory=$False)]
  [Alias('HostName')]
  [string]$ComputerName = "localhost",

  [Parameter(Mandatory=$False)]
  [string]$DiskPath = "C:\"
)

while ($opc -ne 0){

$opc = Read-Host "Elija una opcion: 
1. Top 5 procesos por CPU
2. Discos conectados
3. Archivo mas grande
4. Memoria y swap
5. Conexiones de red activas
0. Salir
"

switch ($opc) {
    1 {
        # Desplegar los cinco procesos que mas CPU estén consumiendo en ese momento
        Write-Output "Procesos que mas CPU estan consumiendo:"
	Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, CPU}

    2 {
        # Desplegar los filesystems o discos conectados a la máquina
        Write-Output "Discos conectados:"
 	Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName | Select DeviceID, Size, FreeSpace | ft @{name="Dispositivo";Expression={$_.DeviceID}}, 	@{name="Tamaño Total (B)";expression={$_.Size}}, @{Name="Espacio Libre (B)";expression={$_.FreeSpace}}
    }

    3 {
        # Desplegar el nombre y el tamaño del archivo más grande en un disco especificado
        Write-Output "`Archivo mas grande del filesystem:"
        $largestFile = Get-ChildItem  | Sort-Object -Property Length -Descending | Select-Object -First 1
	$largestFile | Select-Object FullName, Length | Format-Table @{Name="Ruta";Expression={$_.FullName}}, @{Name="Tamaño 	(Bytes)";Expression={$_.Length}}
    }

    4 {
        # Cantidad de memoria libre y cantidad del espacio de swap en uso
        Write-Output "Cantidad de memoria libre y Swap libre:"
        $memInfo = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName
        $freeMemory = $memInfo.FreePhysicalMemory * 1KB
        $totalMemory = $memInfo.TotalVisibleMemorySize * 1KB
        $swapInUse = $memInfo.TotalVirtualMemorySize * 1KB - $totalMemory
        $swapPercentage = ($swapInUse / $memInfo.TotalVirtualMemorySize * 1KB) * 100
	#$freeMemoryPercentage = ($freeMemory / $totalMemory * 1KB) *100
        [PSCustomObject]@{
            "Memoria Libre (Bytes)" = $freeMemory
	    #"Memoria Libre (%)" = $freeMemoryPercentage
            "Swap en Uso (Bytes)" = $swapInUse
            "Swap en Uso (%)" = $swapPercentage
        } | Format-Table
    }

    5 {
        # Número de conexiones de red activas actualmente (en estado ESTABLISHED)
        Write-Output "`Numero de conexiones de red activas:"
        (Get-NetTCPConnection -State Established).Count
    }

}
}

