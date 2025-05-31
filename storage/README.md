## Storage setup (NFS)

After messing with several storage tools like GlusterFS and Ceph, it made more sense to just go with NFS v4 and manage the /etc/fstab configs manually. SSD's are reliable enough to not need replication and there are ways to set up automatic backups to a NAS in case of data loss to make restoration easier. I really just need a mount point for my docker containers to run different applications.

This article helped with NFS: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04
