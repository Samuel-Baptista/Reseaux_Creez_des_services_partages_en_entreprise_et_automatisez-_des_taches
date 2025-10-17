<#

Auteur : Samuel Baptista
Date : 10/02/2024
Version : 1.0
Révisons : 
- 1.0 : Créations
Description : Script interactif listant les groupes d’un utilisateur et permettant l'export du résultat dans un fichier texte

#>

# Importer le module Active Directory
Import-Module ActiveDirectory

# Demander à l'utilisateur de saisir le nom d'un utilisateur
$nomUtilisateur = Read-Host "Veuillez saisir le nom d'un utilisateur Active Directory"

try {
    # Récupérer les groupes auxquels l'utilisateur appartient
    $groupesUtilisateur = Get-ADUser -Identity $nomUtilisateur | Get-ADPrincipalGroupMembership

    # Afficher les groupes
    Write-Output "Groupes de l'utilisateur $nomUtilisateur :"
    $groupesUtilisateur | ForEach-Object { Write-Output $_.SamAccountName }

    # Demander à l'utilisateur s'il souhaite exporter les résultats dans un fichier texte
    $exporter = Read-Host "Voulez-vous exporter les résultats dans un fichier texte ? (Oui/Non)"
    if ($exporter -eq "Oui" -or $exporter -eq "O") {
        # Demander à l'utilisateur de saisir le chemin du fichier texte
        $cheminFichier = Read-Host "Veuillez saisir le nom complet du fichier texte"

        # Exporter les résultats dans le fichier texte
        $groupesUtilisateur | ForEach-Object { $_.SamAccountName } | Out-File -FilePath $cheminFichier -Encoding UTF8

        Write-Output "Résultats exportés avec succès dans $cheminFichier."
    }
}
catch {
    # Afficher un message d'erreur si l'utilisateur n'est pas trouvé ou s'il n'appartient à aucun groupe
    Write-Error "Erreur : $_"
    Write-Error "Aucun utilisateur trouvé avec le nom $nomUtilisateur ou l'utilisateur n'appartient à aucun groupe."
}