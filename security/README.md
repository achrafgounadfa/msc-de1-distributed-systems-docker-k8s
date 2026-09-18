 PS C:\Users\ilyas\flask-sample-app> docker scout cves achraf2026/flask-sample-app:v1.0 | Out-File -FilePath security/vulnerability-scan.txt -Encoding utf8
    ...Storing image for indexing
    v Image stored for indexing
    ...Indexing
    v Indexed 153 packages
    x Detected 19 vulnerable packages with a total of 62 vulnerabilities

What's next:
    View base image update recommendations → docker scout recommendations achraf2026/flask-sample-app:v1.0

(venv) PS C:\Users\ilyas\flask-sample-app> Get-Content security/vulnerability-scan.txt -Head 40


## Overview

                   Ôöé           Analyzed Image           
ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔö╝ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
 Target            Ôöé  achraf2026/flask-sample-app:v1.0  
   digest          Ôöé  e009389eeb38                      
   platform        Ôöé linux/amd64                        
   vulnerabilities Ôöé    5C    12H    12M    30L     3?  
   size            Ôöé 51 MB                              
   packages        Ôöé 153                                


## Packages and Vulnerabilities

   4C     4H     2M     2L     2?  perl 5.40.1-6
pkg:deb/debian/perl@5.40.1-6?os_distro=trixie&os_name=debian&os_version=13

    x CRITICAL CVE-2026-8376
      https://scout.docker.com/v/CVE-2026-8376?s=debian&n=perl&ns=debian&t=deb&osn=debian&osv=13&vr=%3C5.40.1-6%2Bdeb13u1
      Affected range : <5.40.1-6+deb13u1 
      Fixed version  : 5.40.1-6+deb13u1  
    
    x CRITICAL CVE-2026-42496
      https://scout.docker.com/v/CVE-2026-42496?s=debian&n=perl&ns=debian&t=deb&osn=debian&osv=13&vr=%3C5.40.1-6%2Bdeb13u1
      Affected range : <5.40.1-6+deb13u1 
      Fixed version  : 5.40.1-6+deb13u1  
    
    x CRITICAL CVE-2026-13221
      https://scout.docker.com/v/CVE-2026-13221?s=debian&n=perl&ns=debian&t=deb&osn=debian&osv=13&vr=%3C5.40.1-6%2Bdeb13u1
      Affected range : <5.40.1-6+deb13u1 
      Fixed version  : 5.40.1-6+deb13u1  
    
    x CRITICAL CVE-2026-12087
      https://scout.docker.com/v/CVE-2026-12087?s=debian&n=perl&ns=debian&t=deb&osn=debian&osv=13&vr=%3C5.40.1-6%2Bdeb13u1
      Affected range : <5.40.1-6+deb13u1 
      Fixed version  : 5.40.1-6+deb13u1  
    
    x HIGH CVE-2026-57432
(venv) PS C:\Users\ilyas\flask-sample-app> docker scout sbom --format spdx achraf2026/flask-sample-app:v1.0 | Out-File -FilePath security/sbom.spdx.json -Encoding utf8













