<#

Auteur : Samuel Baptista
Date : 10/02/2024
Version : 1.0
Révisons : 
- 1.0 : Créations
Description : Script de sauvegarde quotidienne de nuit des données utilisateurs situées sur les postes de travail

#>

# Chemin complet du dossier de sauvegarde sur le serveur
$backupPath = "e:\Sauvegardes"

# Liste des ordinateurs dans Active Directory
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

# Définir le chemin du fichier de résultats de la sauvegarde
$filepath = "E:\Sauvegardes\results.txt"

# Parcourir chaque ordinateur et effectuer la sauvegarde
foreach ($computer in $computers) {

    # Chemin du dossier de l'utilisateur sur l'ordinateur distant
    $sourcePath = "\\$computer\Users"

    # Vérifier que le dossier de sauvegarde existe sur le serveur, sinon le créer
    if (!(Test-Path $backupPath)) {
        New-Item -ItemType Directory -Path $backupPath | Out-Null
    }

    # Créer un dossier pour chaque sauvegarde basé sur le nom de l'ordinateur et la date/heure actuelle
    $backupFolder = "$backupPath\$computer"
    $dateAction = Get-Date -Format "yyyyMMddHHmmss"

    # Effectuer la sauvegarde en copiant le dossier de l'utilisateur sur l'ordinateur distant vers le dossier de sauvegarde sur le serveur
    #/MIR (pour synchroniser les répertoires)
    #/COPYALL (pour copier tous les attributs du fichier)
    #/R:0 (pour ne pas réessayer les fichiers qui ont échoué lors de la copie)
    #/W:0 (pour ne pas attendre entre les réessais)
    #/NFL (pour éviter l'affichage des noms de fichiers copiés)
    #/NDL (pour éviter l'affichage des noms des dossiers copiés).
    #/LOG+ pour enregistrer les résultats de la copie dans un fichier journal nommé "robocopy.log" dans le dossier de sauvegarde ($backupFolder)
    #Metttre date et nom du pc pour ne pas remplacer le log anterieur
    if (Test-Path $sourcePath) {
        Robocopy.exe $sourcePath $backupFolder /FFT /MIR /ZB /COPYALL /xj /R:0 /W:0 /B /NFL /NDL /LOG+:E:\log\robocopy$dateAction.log 
        Write-Host "Sauvegarde de $sourcePath vers $backupFolder effectuée avec succès."
    } else {
        Write-Host "Le dossier $sourcePath n'existe pas sur $computer. La sauvegarde a été ignorée."
    }
}

# Écrire le message à l'utilisateur
Write-Host "Les résultats ont été exportés dans le fichier $filepath."