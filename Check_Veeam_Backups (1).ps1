#################################################################################
#################################################################################
####################          Made by Henri PICHON           ####################
#################################################################################
#################################################################################
###  This is a Nagios Plugin destined to check the last status and last run   ###
###        of Veeam Backup & Replication job passed as an argument.           ###
#################################################################################
#################################################################################

# Adding required SnapIn

asnp VeeamPSSnapin

# Global variables

$Fail = $false
$Warning = $false
$period = $args[1]

# Veeam Backup & Replication job status check

$job = Get-VBRJob 
 
#Write-Host "Nombre de job créé :"$job.Count 


# Condition d'entré dans mon programme, si aucun job 
# n'a été créé, la suite du programme ne se réalise pas

if ($job -eq $null)
{
	Write-Host "UNKNOWN! Aucun job de présent sur le serveur VEEAM"
    
	exit 3
}

else
{
    # On va réaliser une suite d'instruction sur chaque
    # objet dans tableau
    for ($i = 0; $i -lt $job.Count; $i++)
    {

        $jobname ="'" + $job[$i].Name + "'" 
        
        $status = $job[$i].GetLastResult()

        #Write-Host $status
        #write-host $jobname

        if($($job.findlastsession()).State -eq "Working")
        {

	        Write-Host "OK - Job: $jobname est en cours de réalisation."
    
        }
    
        if ($status -eq "Failed")
        {
        
	        $Fail = $true
            Write-Host "CRITIQUE! Un element a imterrompu le processus de backup de: $jobname."
            
    
        }


        elseif ($status -ne "Success")
        {
	        
            $Warning = $true
            Write-Host "ATTENTION! Le job $jobname ne s'est pas entierement acheve"

        }

       
	    else
        {
            # Date du dernier Run des jobs

            $now = (Get-Date).AddDays(-$period)
            $now = $now.ToString("yyyy-MM-dd")
            $last = $job.GetScheduleOptions()
            $last = $last -replace '.*Latest run time: \[', ''
            $last = $last -replace '\], Next run time: .*', ''
            $last = $last.split(' ')[0]
            
            # changed by DY on 11/04/2014 based on comment from cmot-weasel at http://exchange.nagios.org/directory/Plugins/Backup-and-Recovery/Others/check_veeam_backups/details
            #if ($now -gt $last)
        
            if((Get-Date $now) -gt (Get-Date $last))
            {
	        
                Write-Host "ATTENTION! date du dernier lancement de: $jobname equivaut au $last"
                exit 1

            } 
    
        }

        
    }
    
    if($Fail -eq $true)
    {

        Write-Host "CRITIQUE! Un element a imterrompu le processus de backup d'un des jobs"
        exit 2
    
    }

    elseif ($Warning -eq $true -And $Fail -eq $false)
    {
    
        Write-Host "ATTENTION! L'un des jobs ne s'est pas entierement acheve"
        exit 1
    
    }
    
    else
    {
    
	    Write-Host "OK! Le processus de backup des jobs s'est acheve avec succes"
        exit 0

    }

}

