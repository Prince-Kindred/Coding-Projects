#Goals
#Check for folder -> if no folder create said folder
#Check for file -> Create file + backup
#User goes in and changes file
#Script checks for changes against backup

param(
[string] $folder, [string] $file1, [string]$backup
)

echo "$folder 7"

if($folder -eq ""){
$folder="C:\MattScript"
$logfile= "C:\MattScript\log.txt"
}
else{
$logfile= "$folder\log.txt"
}
if($file1 -eq ""){
$file1 ="C:\MattScript\test.txt"
}
if($backup -eq ""){
$backup = "C:\MattScript\backup.txt"
}




#Step 1 folder creation/check
if(Test-Path -Path $folder -PathType Container)
{
    Echo "Folder Exists"
}
else
{
    New-Item -Path $folder -ItemType Directory
    Echo "Folder Does not Exist, Making folder"
}

#Step 2 Check for file & backup
if((Test-Path -Path $file1 -PathType Leaf) -and (Test-Path -Path $backup -PathType Leaf))
{
    Echo "File and back up exist"
}
elseif((Test-Path -Path $file1 -PathType Leaf) -and((Test-Path -Path $backup -PathType Leaf) -eq $false))
{
    Copy-Item -Path $file1 -Destination $backup
    Echo "Back up did not exist, backup made"
}
elseif((Test-Path -Path $backup -PathType Leaf) -and((Test-Path -Path $file1 -PathType Leaf) -eq $false))
{
    Copy-Item -Path $backup -Destination $file1
    Echo "Orginal File missing recovering from backup"
}
else
{
    echo "Neither File Exists, making files"
    New-Item -Path $file1 -ItemType File
    "Lorem ipsum dolor sit amet consectetur adipiscing elit. Quisque faucibus ex sapien vitae pellentesque sem placerat. In id cursus mi pretium tellus duis convallis. Tempus leo eu aenean sed diam urna tempor. Pulvinar vivamus fringilla lacus nec metus bibendum egestas. Iaculis massa nisl malesuada lacinia integer nunc posuere. Ut hendrerit semper vel class aptent taciti sociosqu. Ad litora torquent per conubia nostra inceptos himenaeos." | Out-File -FilePath $file1
    "Blicke gesehen, und möcht' ich nun deinen so oft entweihten Namen nie wieder nennen hören! Am 19. Junius Wo ich neulich mit meiner Tänzerin und." | Out-File -FilePath $file1 -Append
    Copy-Item -path $file1 -Destination $backup
}



#Might be able to just amend the file to be clean
if(Test-Path -Path $logfile -PathType Leaf)
{
    Remove-Item -Path $logfile
}
New-Item -Path $logfile -ItemType File



#Step 3 Compare File to Backup

#Concept 1
$file1Content = Get-Content -Path $file1
$backupContent = Get-Content -Path $backup

#Concept 2 w/ File output
$fileCount = (Get-Content -Path $file1).Length
$backupCount =(Get-Content -Path $backup).Length

for($count =0;$count -lt $backupCount; $count++)
{
    
    $backupline =$backupContent[$count]
    $exists= $false
   
    for($count1=0;$count1 -lt $fileCount;$Count1++)
    {
        $fileline = $file1Content[$count1]
        if($fileline -eq $backupline)
        {
            $exists=$true
            if($fileline -cne $backupline)
            {
                $temp=$count+1
                "Case Change on line $temp" | Out-File -FilePath $logfile -Append  
            }
        }
        if($exists -eq $false -and $count1 -eq ($fileCount -1))
        {
            $temp=$count+1
            "Backup file Line $temp was removed that contained content of $backupline" | Out-File -FilePath $logfile -Append  
            $reported = $true  
        }
    }
}

for($x =0;$x -lt $fileCount; $x++)
{
    $fileline =$file1Content[$x]
    $exists= $false
    for($y=0;$y -lt $backupCount;$y++)
    {
        $backupline = $backupContent[$y]
        if($fileline -eq $backupline)
        {
            $exists=$true
        }
        if($exists -eq $false -and $y -eq ($backupcount -1))
        {
            $temp=$x+1
            "New file Line $temp was add with the following content $fileline" | Out-File -FilePath $logfile -Append    
        }
    }
}



#Error Counter

$NewError=0
$OldError=0
for($count=0; $count -lt $fileCount; $count++)
{
    $fileline =$file1Content[$count]
    if($fileline -like "*error*")
    {
        $temp=$count+1
        "New File Line $temp Contains Error" | Out-File -FilePath $logfile -Append 
        $newerror++
    }
}
for($count=0; $count -lt $backupCount; $count++)
{
    $backupline =$backupContent[$count]
    if($backupline -like "*error*")
    {
        $temp=$count+1
        "Backup File Line $temp Contains Error" | Out-File -FilePath $logfile -Append
        $olderror++ 
    }
}
if($NewError -gt 0 -or $OldError -gt 0)
{
    "New File Contains: $NewError Errors" | Out-File -FilePath $logfile -Append
    "Backup File Contains: $OldError Errors" | Out-File -FilePath $logfile -Append
}

$pattern= Read-Host -Prompt "Pattern to search for"


for($count =0;$count -lt $backupCount; $count++)
{
    
    $backupline =$backupContent[$count]
   if($backupline -like "*$pattern*")
   {
        $temp = $count+1
         "Line $temp on backup contains pattern" | Out-File -FilePath $logfile -Append

   }
   
}

for($x =0;$x -lt $fileCount; $x++)
{
    $fileline =$file1Content[$x]
    if($fileline -like "*$pattern*")
   {
        $temp = $count+1
         "Line $temp on current contains pattern" | Out-File -FilePath $logfile -Append

   }
}






#Step 5 Replace Backup

$userinput = Read-Host -Prompt "Would you Like to Replace Backup? Yes or No"
if($userinput -eq "Yes")
{
    Copy-Item -path $file1 -Destination $backup
}