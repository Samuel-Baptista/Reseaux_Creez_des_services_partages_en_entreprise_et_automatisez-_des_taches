<#

Auteur : Samuel Baptista
Date : 10/02/2024
Version : 1.0
Révisons : 
- 1.0 : Créations
Description :Un script interactif listant les membres d’un groupe de sécurité et permettant l'export du résultat dans un fichier texte

#>

# Importer le module Active Directory
Import-Module ActiveDirectory

# Demander à l'utilisateur de saisir le nom d'un groupe de sécurité
$nomGroupe = Read-Host "Veuillez saisir le nom d'un groupe de sécurité Active Directory"

try {
    # Récupérer les membres du groupe de sécurité
    $membresGroupe = Get-ADGroupMember -Identity $nomGroupe

    # Afficher les membres du groupe
    Write-Output "Membres du groupe de sécurité $nomGroupe :"
    $membresGroupe | ForEach-Object { Write-Output $_.SamAccountName }

    # Demander à l'utilisateur s'il souhaite exporter les résultats dans un fichier texte
    $exporter = Read-Host "Voulez-vous exporter les résultats dans un fichier texte ? (Oui/Non)"
    if ($exporter -eq "Oui" -or $exporter -eq "O") {
        # Demander à l'utilisateur de saisir le chemin du fichier texte
        $cheminFichier = Read-Host "Veuillez saisir le nom complet du fichier texte"

        # Exporter les résultats dans le fichier texte
        $membresGroupe | ForEach-Object { $_.SamAccountName } | Out-File -FilePath $cheminFichier -Encoding UTF8

        Write-Output "Résultats exportés avec succès dans $cheminFichier."
    }
}
catch {
    # Afficher un message d'erreur si le groupe n'est pas trouvé ou s'il ne contient aucun membre
    Write-Error "Erreur : $_"
    Write-Error "Aucun groupe de sécurité trouvé avec le nom $nomGroupe ou le groupe ne contient aucun membre."
}