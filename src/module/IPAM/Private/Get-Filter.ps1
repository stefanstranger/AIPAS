<#
    From Jabub Jaris. More info here: https://gist.github.com/nohwnd/3a0a1711407eb28e9cde1cc734e1aa27

    Example usage:   


    $filter = Get-Filter ([PSCustomObject]@{
        Name = "Jakub"
        Age = 33
    })

    $result = @( 
        [PSCustomObject]@{
            Name = "Jakub"
            Age = 55
            HasDog = $false
        }

        [PSCustomObject]@{
            Name = "Thomas"
            Age = 33
            HasDog = $false
        }

        [PSCustomObject]@{
            Name = "Jakub"
            Age = 33
            HasDog = $false
        }

    ) | Where-Object $filter

    "Got $(@($result).Count) object, with value: $result"

    ## output: 
    # Got 1 object, with value: @{Name=Jakub; Age=33; HasDog=False}
    #>

Function Get-Filter ($Predicate) { 

    # gets the property hashtable of an object
    $properties = $Predicate.PSObject.Properties

    # runs the code below in a scriptblock to ensure that we only capture 
    # the desired $Properties variable in case we would have more variables 
    # in this function. This is not strictly necessary, but closure only captures
    # local variables so it is useful trick to limit the variables that we capture.
    & {
        param ($Properties)

        # this returns a scriptblock that we "generated". Because we captured 
        # a clousure, the $Properties variable will be bound to this scriptblock
        # and it will resolve to the correct $Properties variable, no matter where 
        # we execute this scriptblock. If we did not capture closure it would try to 
        # get the variable from the scope (and parent scopes) of where we execute it,
        # which might still work in some cases, but not in others.
        {
            foreach ($property in $Properties) {
                # instead of generating a string with "value" -eq $_.Name, we just iterate
                # over all values and check if they are equal, once we found one that does not match
                # we return false to "simulate" -and

                if ($property.Value -ne $_.($property.Name)) { 
                    return $false
                }
            }

            return $true
        }.GetNewClosure()
    } $properties
}