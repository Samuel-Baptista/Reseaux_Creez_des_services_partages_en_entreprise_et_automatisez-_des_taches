<#
Auteur : Samuel Baptista
Date : 10/02/2024
Version : 1.1
Révision : Aucune
Description: script de création d’utilisateur dans l'AD

Consignes Axeplane:
1.Être documenté (nom de l'auteur, date, versioning, description,
commentaires sur les commandes utilisées et le comportement du script);
2. Retourner une information selon l’état directement dans la console ou dans
un fichier de log (message ou code en cas d'erreur/réussite) ;
- Ne pas contenir d'information en dur (utilisation de variables).
#>

# Présentation programme 
Write-Host "Bienvenu $Env:USERNAME sur" -ForegroundColor Cyan
Write-Host "Créateur de Nouvel Utilisateur pour AXELPLANE" -ForegroundColor Red -BackgroundColor Black
Write-Host "Le script facilite l'ajout d'un nouvel utilisateur ainsi que la création d'un dossier partagé correspondant sur le domaine AXELPLANE.." -ForegroundColor Magenta
Write-Host "# Ce script a été développé par S. Baptista, un étudiant OPENCLASSROOMS" -ForegroundColor Cyan

# Identification Nouvel utilisateur
# Variable nom 
$nom = Read-Host "Bonjour, commencez par entrer le nom du nouveau utilisateur:"

# Variable Prénom
$prenom = Read-Host "Et maintenant le prénom"

# Creation Nom Complet
$nomComplet = "$prenom $nom"

# Informer le nom du nouvel utilisateur
Write-Host "Bravo! Le nouveau utilisateur est $nomComplet"

# Variable login de l'utilisateur (GÉNÉRÉE AUTOMATIQUEMENT EN SUPPRIMANT LES CARACTÈRES SPÉCIAUX)

# Prendre la première lettre du prénom ($prenom[0]), un point et le nom, en supprimant les caractères spéciaux (-replace "[^a-zA-Z]") et en convertissant en minuscules[.ToLower()]
$login = (($prenom[0] -replace "[^a-zA-Z]","").ToLower() + "." + ($nom -replace "[^a-zA-Z]","").ToLower())

# Vérifier si le login existe déjà dans l'AD
if (Get-ADUser -Filter {SamAccountName -eq $login}) {
    
    # Si le login existe déjà, utiliser les deux premières lettres du prénom pour créer le login
    $login = ($prenom.Substring(0,2).ToLower() + "." + ($nom -replace "[^a-zA-Z]","").ToLower())
}

Write-Host "Le login créé est : $login"

# Afficher mail du nouveau utilisateur
Write-Host "Et son nouvel adresse e-mail est : $login@axeplane.loc"

# Définir le mot de passe
$UtilisateurMotDePasse = "Bfvqzzax34@"

# Afficher le mot de passe
Write-Host "# Le mot de passe du nouvel utilisateur Axeplane est: $UtilisateurMotDePasse"

# Choix de l'OU
$UtilisateurOU = (Get-ADOrganizationalUnit -Filter *).Name | Out-GridView -Title "Choisissez une OU pour cet utilisateur" -PassThru

# Vérifier la présence de l'utilisateur dans l'AD
if (Get-ADUser -Filter {SamAccountName -eq $login}) {
    Write-Warning "L'identifiant $login existe déjà dans l'AD"
    Break
} else {
    New-ADUser -Name "$nom $prenom" `
               -DisplayName "$nomComplet" `
               -GivenName $prenom `
               -Surname $nom `
               -SamAccountName $login `
               -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
               -UserPrincipalName "$login@$((Get-ADDomain).DNSRoot)" `
               -Path "OU=$UtilisateurOU,DC=axeplane,DC=loc" `
               -EmailAddress "$login@axeplane.loc" `
               -Title $Utilisateur `
               -Enabled $true
            
}

# Assigner la nouvelle valeur de groupe basée sur l'unité d'organisation à une variable
$GRP_UtilisateurOU = "GRP_" + $UtilisateurOU
Add-ADGroupMember -Identity "$GRP_UtilisateurOU" -Members $login

# Spécification du chemin du dossier partagé (inclus le nom du dossier partagé lui-même)
$cheminDossier = "E:\Partages Personnels Utilisateurs\$login"

# Création du dossier partagé en utilisant la cmdlet New-Item
New-Item -ItemType Directory -Path $cheminDossier

# Récupération de la liste des autorisations du dossier partagé en utilisant la cmdlet Get-Acl
$acl = Get-Acl -Path "$cheminDossier"

# Définition des nouvelles autorisations pour l'utilisateur
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("AXEPLANE\$login", "Modify", "ContainerInherit, ObjectInherit", "None", "Allow")

# Ajout de la nouvelle autorisation à la liste
$acl.AddAccessRule($rule)

# Application des modifications à l'aide de la cmdlet Set-Acl
Set-Acl -Path "$cheminDossier" -AclObject $acl


# Création du partage SMB
New-SmbShare -Name "${login}$" -Path $cheminDossier -FullAccess "$login"

# Résumé des informations importantes à retenir
Write-Host "RÉCAPITULATIF:" -ForegroundColor Magenta
Write-Host "# Création de l'utilisateur:"
Write-Host "$NomComplet" -ForegroundColor Magenta
Write-Host "# Le login est:"
Write-Host "$login" -ForegroundColor Magenta
Write-Host "# Le mot de passe est:"
Write-Host "$UtilisateurMotDePasse" -ForegroundColor Magenta
Write-Host "# L'adresse e-mail est:"
Write-Host "$login@axeplane.loc" -ForegroundColor Magenta
Write-Host "# $Nom appartient à :"
Write-Host "$UtilisateurOU" -ForegroundColor Magenta
Write-Host "# Le dossier partagé est:"
Write-Host "$cheminDossier" -ForegroundColor Cyan

# Obtenir la date actuelle
$dateAction = Get-Date -Format "yyyy/MM/dd HH:mm:ss"

# Date de clôture 
Write-host "La création du nouvel utilisateur a été conclue:"
Write-host "$dateAction"
Write-host "S.B Script vous remercie de votre collaborations"-ForegroundColor Magenta