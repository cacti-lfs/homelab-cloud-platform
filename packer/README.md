# PACKER : Templatiser les ressources de VM

Une VM a des besoins en ressources différentes selon les services qu'elle héberge et les données qu'elle traite. Pour gérer cette diversité, il est nécessaire d'utiliser des images (templates) sur les hypervisuers comme Proxmox.

C'est dans ce cadre qu'intervient Packer : il permet de créer ces images de manière automatisée, reproductible et versionnée pour plusieurs plateformes, minimisant ainsi les interventions manuelles.

