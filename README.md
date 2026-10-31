# OuiStudio

Application React + Vite pour créer des invitations personnalisées, partager un lien et collecter une réponse.

## Lancer en local

```bash
npm install
cp .env.example .env
npm run dev
```

Sans variables Supabase, le prototype fonctionne en **mode local** avec `localStorage` (les invitations restent sur le navigateur qui les a créées). Ce mode est utile pour tester le parcours visuel, mais ne fournit ni comptes multi-appareils ni synchronisation publique.

## Activer Supabase

1. Créer un projet Supabase.
2. Copier l'URL du projet et la clé anon dans `.env` (`VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`).
3. Exécuter `supabase/schema.sql` dans le SQL Editor.
4. Activer Supabase Auth et configurer les fournisseurs souhaités.
5. Déployer l'application sur Vercel et définir les mêmes variables d'environnement.

### État de l'intégration dans cette version

- Le client Supabase est initialisé si les variables existent.
- La création d'invitation et l'ajout des créneaux utilisent Supabase si un utilisateur est déjà authentifié ; sinon le mode local est utilisé.
- L'authentification, le chargement public d'une invitation depuis son slug sur un autre appareil, la lecture sécurisée du tableau de bord depuis Supabase et l'enregistrement public des réponses doivent être finalisés avant une mise en production. Le tableau de bord local ne doit pas être considéré comme un espace privé.
- Le schéma SQL active RLS et donne aux propriétaires la gestion de leurs données. Les lectures publiques par slug/slots sont ouvertes pour le parcours invité ; en production, remplacer ces politiques larges par une fonction RPC/Edge Function qui ne révèle que les données publiques nécessaires.
- L'insertion de réponses publiques est volontairement non autorisée par une policy SQL ouverte. Créer une Edge Function de réponse avec validation du slug, vérification du créneau, limitation de débit et protection anti-spam.

## E-mails

La fonction `supabase/functions/notify` est un exemple d'envoi avec Resend. Définir `RESEND_API_KEY` et `APP_FROM_EMAIL` comme secrets Supabase. Ajouter une vérification d'autorisation et un appel serveur fiable depuis la fonction de réponse avant de l'utiliser en production.

## Fonctionnalités de démonstration

- Landing page responsive et aperçu interactif.
- Formulaire de création avec aperçu en direct, thèmes et plusieurs créneaux.
- Liens d'invitation à slug aléatoire dans le navigateur courant.
- Bouton « Non » qui esquive la souris et le toucher ; un lien de refus accessible permet de décliner.
- Choix d'un créneau, message facultatif, tableau de bord local, copie et partage WhatsApp/SMS/e-mail.

Ne pas présenter cette version comme une application de production tant que les éléments d'intégration listés ci-dessus ne sont pas terminés et testés.
