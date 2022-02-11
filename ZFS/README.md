#Работа с файловой системой ZFS
## 1. Определение алгоритма с наилучшим сжатием
#### 1.1. переходим в режим суперпользователя
    [vagrant@localhost ~]$ sudo -i

#### 1.2. проверяем наличие дисков
    [root@localhost ~]lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda      8:0    0   40G  0 disk 
    `-sda1   8:1    0   40G  0 part /
    sdb      8:16   0  512M  0 disk 
    sdc      8:32   0  512M  0 disk 
    sdd      8:48   0  512M  0 disk 
    sde      8:64   0  512M  0 disk 
    sdf      8:80   0  512M  0 disk 
    sdg      8:96   0  512M  0 disk 
    sdh      8:112  0  512M  0 disk 
    sdi      8:128  0  512M  0 disk 


#### 1.3. cоздаём пул из двух дисков в режиме RAID 1
    [root@localhost ~]# zpool create mahsn1 mirror sdb sdc
    [root@localhost ~]# zpool create mahsn2 mirror sdd sde
    [root@localhost ~]# zpool create mahsn3 mirror sdf sdg
    [root@localhost ~]# zpool create mahsn3 mirror sdh sdi
    [root@localhost ~]# zpool status
      pool: mahsn1
      state: ONLINE
      scan: none requested
    config:

        NAME        STATE     READ WRITE CKSUM
        mahsn1      ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

    errors: No known data errors

     pool: mahsn2
    state: ONLINE
      scan: none requested
    config:

            NAME        STATE     READ WRITE CKSUM
            mahsn2      ONLINE       0     0     0
              mirror-0  ONLINE       0     0     0
                sdd     ONLINE       0     0     0
                sde     ONLINE       0     0     0

    errors: No known data errors

      pool: mahsn3
    state: ONLINE
      scan: none requested
    config:

            NAME        STATE     READ WRITE CKSUM
            mahsn3      ONLINE       0     0     0
              mirror-0  ONLINE       0     0     0
                sdf     ONLINE       0     0     0
                sdg     ONLINE       0     0     0

    errors: No known data errors

      pool: mahsn4
    state: ONLINE
      scan: none requested
    config:

            NAME        STATE     READ WRITE CKSUM
            mahsn4      ONLINE       0     0     0
              mirror-0  ONLINE       0     0     0
                sdh     ONLINE       0     0     0
                sdi     ONLINE       0     0     0

    errors: No known data errors
#### 1.4. проверяем созданный пул    
    [root@localhost ~]# zpool list                        
    NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
    mahsn1   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    mahsn2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    mahsn3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    mahsn4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
    [root@localhost ~]# lsblk
    NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    sda      8:0    0   40G  0 disk 
    `-sda1   8:1    0   40G  0 part /
    sdb      8:16   0  512M  0 disk 
    |-sdb1   8:17   0  502M  0 part 
    `-sdb9   8:25   0    8M  0 part 
    sdc      8:32   0  512M  0 disk 
    |-sdc1   8:33   0  502M  0 part 
    `-sdc9   8:41   0    8M  0 part 
    sdd      8:48   0  512M  0 disk 
    |-sdd1   8:49   0  502M  0 part 
    `-sdd9   8:57   0    8M  0 part 
    sde      8:64   0  512M  0 disk 
    |-sde1   8:65   0  502M  0 part 
    `-sde9   8:73   0    8M  0 part 
    sdf      8:80   0  512M  0 disk 
    |-sdf1   8:81   0  502M  0 part 
    `-sdf9   8:89   0    8M  0 part 
    sdg      8:96   0  512M  0 disk 
    |-sdg1   8:97   0  502M  0 part 
    `-sdg9   8:105  0    8M  0 part 
    sdh      8:112  0  512M  0 disk 
    |-sdh1   8:113  0  502M  0 part 
    `-sdh9   8:121  0    8M  0 part 
    sdi      8:128  0  512M  0 disk 
    |-sdi1   8:129  0  502M  0 part 
    `-sdi9   8:137  0    8M  0 part 
#### 1.5. добавим разные алгоритмы сжатия в каждую файловую систему
    [root@localhost ~]# zfs set compression=lzjb mahsn1
    [root@localhost ~]# zfs set compression=lz4 mahsn2
    [root@localhost ~]# zfs set compression=gzip-9 mahsn3
    [root@localhost ~]# zfs set compression=zle mahsn4
#### 1.6. проверим, что все файловые системы имеют разные методы сжатия
    [root@localhost ~]# zfs get all | grep compression
    mahsn1  compression           lzjb                   local
    mahsn2  compression           lz4                    local
    mahsn3  compression           gzip-9                 local
    mahsn4  compression           zle                    local
#### 1.7. скачаем один и тот же текстовый файл во все созданные файловые системы
    [root@localhost ~]# for i in {1..4}; do wget -P /mahsn$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done
    --2022-02-02 06:19:23--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
    Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 40776001 (39M) [text/plain]
    Saving to: '/mahsn1/pg2600.converter.log'

    100%[=====================================================================================================================================================================>] 40,776,001  1.89MB/s   in 18s    

    2022-02-02 06:19:43 (2.15 MB/s) - '/mahsn1/pg2600.converter.log' saved [40776001/40776001]

    --2022-02-02 06:19:43--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log 
    Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
    Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 40776001 (39M) [text/plain]
    Saving to: '/mahsn2/pg2600.converter.log'

    100%[=====================================================================================================================================================================>] 40,776,001  2.55MB/s   in 16s    

    2022-02-02 06:20:00 (2.38 MB/s) - '/mahsn2/pg2600.converter.log' saved [40776001/40776001] 

    --2022-02-02 06:20:00--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
    Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 40776001 (39M) [text/plain]
    Saving to: '/mahsn3/pg2600.converter.log'

    100%[=====================================================================================================================================================================>] 40,776,001  1.49MB/s   in 26s    

    2022-02-02 06:20:27 (1.48 MB/s) - '/mahsn3ls/pg2600.converter.log' saved [40776001/40776001]

    --2022-02-02 06:20:27--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
    Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
    Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 40776001 (39M) [text/plain]
    Saving to: '/mahsn4/pg2600.converter.log'

    100%[=====================================================================================================================================================================>] 40,776,001  2.02MB/s   in 22s    

    2022-02-02 06:20:50 (1.73 MB/s) - '/mahsn4/pg2600.converter.log' saved [40776001/40776001]
#### 1.8. смотрим занятый объем 
      [root@localhost ~]# zfs list
    NAME     USED  AVAIL     REFER  MOUNTPOINT
    mahsn1  21.6M   330M     21.5M  /mahsn1
    mahsn2  17.6M   334M     17.6M  /mahsn2
    mahsn3  10.8M   341M     10.7M  /mahsn3
    mahsn4  39.0M   313M     38.9M  /mahsn4
#### 1.9. смотрим коэффициент сжатия
[root@localhost ~]# zfs get all | grep compressratio | grep -v ref
mahsn1  compressratio         1.81x                  -
mahsn2  compressratio         2.22x                  -
mahsn3  compressratio         3.64x                  -
mahsn4  compressratio         1.00x                  -

### Вывод: Алгоритм сжатия  gzip-9 наиболее эффективный. 

## 2  Определение настроек пула
#### 2.1. скачиваем необходимый файл
    [root@zfs ~]# wget -O archive.tar.gz 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
    --2022-02-09 09:36:00--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
    Resolving drive.google.com (drive.google.com)... 142.251.1.194, 2a00:1450:4010:c1e::c2
    Connecting to drive.google.com (drive.google.com)|142.251.1.194|:443... connected.
    HTTP request sent, awaiting response... 302 Moved Temporarily
    Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/pl6fj4s8vk8ocirnqcaqm7cinjlb7u67/1644399300000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download [following]
    Warning: wildcards not supported in HTTP.
    --2022-02-09 09:36:06--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/pl6fj4s8vk8ocirnqcaqm7cinjlb7u67/1644399300000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download
    Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 209.85.233.132, 2a00:1450:4010:c0d::84
    Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|209.85.233.132|:443... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 7275140 (6.9M) [application/x-gzip]
    Saving to: 'archive.tar.gz'

    100%[============================================================================================================================================================>] 7,275,140   2.32MB/s   in 3.0s   

    2022-02-09 09:36:10 (2.32 MB/s) - 'archive.tar.gz' saved [7275140/7275140]

#### 2.2. смотрим размер скаченношо архива 
    [root@zfs ~]# ls -la
    ...
    -rw-r--r--.  1 root root 7275140 Feb  9 09:36 archive.tar.gz
    ...
   
#### 2.3. распаковываем архив archive.tar.cfg
    [root@zfs ~]# tar -xzvf archive.tar.gz
    zpoolexport/
    zpoolexport/filea
    zpoolexport/fileb
    [root@zfs ~]# ls                      
    anaconda-ks.cfg  archive.tar.gz  original-ks.cfg  otus_task2.file  zpoolexport

#### 2.4. проверим, возможно ли импортировать данный каталог в пул
    [root@zfs ~]# zpool import -d zpoolexport                  
      pool: otus
        id: 6554193320433390805
      state: ONLINE
    action: The pool can be imported using its name or numeric identifier.
    config:

            otus                         ONLINE
              mirror-0                   ONLINE
                /root/zpoolexport/filea  ONLINE
                /root/zpoolexport/fileb  ONLINE
#### 2.3. импортируем данный пул к нам в ОС 
    [root@zfs ~]# zpool import -d zpoolexport/ otus                             
    [root@zfs ~]# zpool status
    pool: otus
    state: ONLINE
      scan: none requested
    config:

            NAME                         STATE     READ WRITE CKSUM
           otus                         ONLINE       0     0     0
             mirror-0                   ONLINE       0     0     0
               /root/zpoolexport/filea  ONLINE       0     0     0
               /root/zpoolexport/fileb  ONLINE       0     0     0

    errors: No known data errors

#### 2.4. запрос сразу всех параметром файловой системы 
    [root@zfs ~]# zpool get all otus
    NAME  PROPERTY                       VALUE                          SOURCE
    otus  size                           480M                           -
    otus  capacity                       0%                             -
    otus  altroot                        -                              default
    otus  health                         ONLINE                         -
    otus  guid                           6554193320433390805            -
    otus  version                        -                              default
    otus  bootfs                         -                              default
    otus  delegation                     on                             default
    otus  autoreplace                    off                            default
    otus  cachefile                      -                              default
    otus  failmode                       wait                           default
    otus  listsnapshots                  off                            default
    otus  autoexpand                     off                            default
    otus  dedupditto                     0                              default
    otus  dedupratio                     1.00x                          -
    otus  free                           478M                           -
    otus  allocated                      2.09M                          -
    otus  readonly                       off                            -
    otus  ashift                         0                              default
    otus  comment                        -                              default
    otus  expandsize                     -                              -
    otus  freeing                        0                              -
    otus  fragmentation                  0%                             -
    otus  leaked                         0                              -
    otus  multihost                      off                            default
    otus  checkpoint                     -                              -
    otus  load_guid                      16586541713756378586           -
    otus  autotrim                       off                            default
    otus  feature@async_destroy          enabled                        local
    otus  feature@empty_bpobj            active                         local
    otus  feature@lz4_compress           active                         local
    otus  feature@multi_vdev_crash_dump  enabled                        local
    otus  feature@spacemap_histogram     active                         local
    otus  feature@enabled_txg            active                         local
    otus  feature@hole_birth             active                         local
    otus  feature@extensible_dataset     active                         local
    otus  feature@embedded_data          active                         local
    otus  feature@bookmarks              enabled                        local
    otus  feature@filesystem_limits      enabled                        local
    otus  feature@large_blocks           enabled                        local
    otus  feature@large_dnode            enabled                        local
    otus  feature@sha512                 enabled                        local
    otus  feature@skein                  enabled                        local
    otus  feature@edonr                  enabled                        local
    otus  feature@userobj_accounting     active                         local
    otus  feature@encryption             enabled                        local
    otus  feature@project_quota          active                         local
    otus  feature@device_removal         enabled                        local
    otus  feature@obsolete_counts        enabled                        local
    otus  feature@zpool_checkpoint       enabled                        local
    otus  feature@spacemap_v2            active                         local
    otus  feature@allocation_classes     enabled                        local
    otus  feature@resilver_defer         enabled                        local
    otus  feature@bookmark_v2            enabled                        local
#### 2.5. c помощью команды grep уточняем конкретные параметры, например:
##### 2.5.1. размер: zfs get available otus
    [root@zfs ~]# zfs get available otus
    NAME  PROPERTY   VALUE  SOURCE
    otus  available  350M   -
##### 2.5.2. тип: zfs get readonly otus
    [root@zfs ~]# zfs get readonly otus
    NAME  PROPERTY  VALUE   SOURCE
    otus  readonly  off     default
##### 2.5.3. значение recordsize: zfs get recordsize otus
    [root@zfs ~]# zfs get recordsize otus
    NAME  PROPERTY    VALUE    SOURCE
    otus  recordsize  128K     local
##### 2.5.4. тип сжатия (или параметр отключения): zfs get compression otus
    [root@zfs ~]# zfs get compression otus
    NAME  PROPERTY     VALUE     SOURCE
    otus  compression  zle       local
##### 2.5.5. тип контрольной суммы: zfs get checksum otus
    [root@zfs ~]# zfs get checksum otus
    NAME  PROPERTY  VALUE      SOURCE
    otus  checksum  sha256     local

## 3 Работа со снапшотом, поиск сообщения от преподавателя
##### необходимый snapshot (otus_task2.file) был скачен на хостовую машину и передан в виртуальную машину через синхронизацию папок (функция rsync) 
#### 3.1. cоздаём пул из двух дисков в режиме RAID 1
    [root@zfs ~]# zpool create mahsn1 mirror sdb sdc
    [root@zfs ~]# zpool list
    NAME     SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
    mahsn1   960M  91.5K   960M        -         -     0%     0%  1.00x    ONLINE  -
#### 3.2. смотрим файловую систему
    [root@zfs ~]# zfs list
    NAME     USED  AVAIL     REFER  MOUNTPOINT
    mahsn1  94.5K   832M       24K  /mahsn1
#### 3.3. восстановим файловую систему из снапшота
    [root@zfs ~]# zfs receive mahsn1/test@today < /vagrant/otus_task2.file
#### 3.4. проверяем восстановление из снапшота
    [root@zfs ~]# zfs list
    NAME          USED  AVAIL     REFER  MOUNTPOINT
    mahsn1       3.83M   828M     25.5K  /mahsn1
    mahsn1/test  3.69M   828M     3.69M  /mahsn1/test
#### 3.5. смотрим наличие файлов в восстоновленной файловой системы
[root@zfs ~]# ls /mahsn1/test/
10M.file  Limbo.txt  Moby_Dick.txt  War_and_Peace.txt  cinderella.tar  for_examaple.txt  homework4.txt  task1  world.sql
#### 3.6. выполняем поиск нужного файла 'secret_message'
[root@zfs ~]# find /mahsn1/test -name "secret_message"
/mahsn1/test/task1/file_mess/secret_message
#### 3.7. выводим информацию находящиейся в файле 'secret_message'
[root@zfs ~]# cat /mahsn1/test/task1/file_mess/secret_message
### информация которая находилась в файле и которую искали
https://github.com/sindresorhus/awesome