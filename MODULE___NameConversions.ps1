<#
.SYNOPSIS
Convert a canonical name to distinguishedname

.DESCRIPTION
Convert a canonical name like "domain.com/department/team" to distinguishedname form "OU=team,CN=department,DC=domain,DC=com"

.PARAMETER CanonicalName
Hold the canonicalname to convert

PIPELINE: supported

.PARAMETER UseCN
SWITCH: will output the first part of the DN as CN instead of OU

.EXAMPLE
ConvertTo-DistinguishedName -CanonicalName 'blackmesa.net/Science/Physics/Einstein Albert' -UseCN

Converts the CanonicalName of Mr Einstein to its DistinguishedName form:
'CN=EINSTEIN Albert,OU=Physics,OU=Science,DC=blackmesa,DC=net'

.EXAMPLE
Get-Mailbox einstein | Foreach-Object { ConvertTo-DistinguishedName $_.OrganizationalUnit }

Converts the OrganizationalUnit returned by Get-Mailbox to its distinguishedname form:
'OU=Physics,OU=Science,DC=blackmesa,DC=net'

.NOTES
Maximilian Otter, 2019
#>

function ConvertTo-DistinguishedName {
    param (
        [Parameter(ValueFromPipeline,Position=0)]
        [string]$CanonicalName,
        [switch]$UseCN
    )

    process {
        if ($CanonicalName -match '\w+(\.\w+)(\/.+)*') {
            $DistinguishedName = ''
            $NameParts = $CanonicalName -split '/'                                                          # Split Canonicalname in domain and OUs
            if ($NameParts.Count -gt 1) {
                $DistinguishedName = ',DC=' + ($NameParts[0].Split('.') -join ',DC=')                           # convert domain to ',DC=' sequence
                $DistinguishedName = ($NameParts[($NameParts.Count-1)..1] -join ',OU=') + $DistinguishedName    # join OUs in reversed order and add DC sequence

                if (!$UseCN) {                                                                                  # add the desired prefix
                    'OU=' + $DistinguishedName
                } else {
                    'CN=' + $DistinguishedName
                }                 
            } else {
                'DC=' + ($NameParts[0].Split('.') -join ',DC=') 
            }
           
        } else {
            Write-Error "`"$CanonicalName`" does not look like an AD path (domain.ext/ouone/outwo/..)."
        }
    }
}



<#
.SYNOPSIS
Convert a distinguishedname to canonicalname/path

.DESCRIPTION
Convert a distinguishedname like "OU=team,CN=department,DC=domain,DC=com" to canonicalname/path like "domain.com/department/team". "CN=" is supported.

.PARAMETER DistinguishedName
Holds the distinguishedname to convert

PIPELINE: supported by property name

.EXAMPLE
Get-ADUser einstein | ConvertTo-CanonicalName

Converts the string in the AD User's property DistinguishedName into canonicalname/path form

.EXAMPLE
ConvertTo-CanonicalName -DistinguishedName 'CN=EINSTEIN Albert,OU=Physics,OU=Science,DC=blackmesa,DC=net'

Will result in 'blackmesa.net/Science/Physics/Einstein Albert'

.NOTES
Maximilian Otter, 14.01.2020
#>
function ConvertTo-CanonicalName {
    param (
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0)]
        [string]$DistinguishedName
    )

    process {

        if ($DistinguishedName -match '^(CN=[ a-zA-Z0-9_\-\(\)]+,)?(OU=[ a-zA-Z0-9_\-\(\)]+,)*(DC=[ a-zA-Z0-9_\-\(\)]+(,DC=[ a-zA-Z0-9_\-\(\)]+)+)$') {
            $DCParts = $DistinguishedName -split ',?DC='                        # get domain parts (,DC=...,DC=...), comma might not be present, if we don't have OUs in front
            $Domain = $DCParts[1..($DCParts.Count-1)] -join '.'                 # join them with dots, skip the first item [0], it's just OUs
            $OUParts = (($DCParts[0] -replace '^CN=') -split ',?OU=').Where{$_} # split the single domains and remove any leading CN=; skip empty items (where{$_})
            if ($OUParts.Count -gt 0) {
                $OUParts = $OUParts[($OUParts.Count-1)..0] -join '/'                # join OUs together with '/'
                @($Domain,$OUParts) -join '/'                                       # join domain and OUs with '/' and return the result
            } else {
                $Domain
            }            
        } else {
            Write-Error "`"$DistinguishedName`" does not look like a real distinguishedname (e.g. CN=LastName FirstName,OU=Users,OU=Finance,DC=Domain,DC=tld). Allowed characters are `" a-zA-Z0-9_-()`"."
        }


    }
}



<#
.SYNOPSIS
    Switch-Name

    Takes a string of space separated words and turns it around.
.DESCRIPTION
    Switch-Name's intended use is to take a name, like 'Charlie Brown' and return it as 'Brown Charlie'.
    However, it is designed to take any space separated string and reverse the word order.
.EXAMPLE
    Standard usage:

    Switch-Name -Name 'Charlie Brown'

    Output: 'Brown Charlie'
.EXAMPLE
    Pipeline usage:
    
    'Charlie Brown' | Switch-Name

    Output: 'Brown Charlie'
.EXAMPLE
    Empty input objects or multiple spaces between words will be ignored:

    [string[]]$Names = @(
        'Marty McFly'
        'Jennifer McFly'
        ''
        'George   McFly'
    )
    $Names | Switch-Name

    Output:
    McFly Marty
    McFly Jennifer
    McFly George

.NOTES
    by Maximilian Otter, 2019
#>
function Switch-Name {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]$Name
    )
    
    process {
        if ($Name -match '\w+ +\w+') {
            $Splits = $Name -split ' +'
            ($Splits[($Splits.Count-1)..0] -join ' ').trim(' ')
        } else {
            Write-Error "`"$Name`" does not look like a name."
        }
    }
}