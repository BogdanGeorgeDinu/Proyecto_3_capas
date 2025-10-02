# Proyecto: Arquitectura Web de 3 Capas en AWS con Terraform

En este proyecto, construí una infraestructura web completa en Amazon Web Services desde cero, utilizando Terraform para automatizar todo el proceso.

---

Mi Objetivo con este Proyecto

Después de sacarme la certificación AWS Solutions Architect - Associate, quería poner en práctica todo lo aprendido. Mi meta era construir un entorno realista que cumpliera con los estándares de la industria, centrándome en la seguridad, la disponibilidad y la automatización.
Este proyecto me sirvió para demostrar mi manejo de:

Infraestructura como Código: Cómo planificar y desplegar recursos en la nube de forma predecible y repetible.

Arquitecturas Seguras: La importancia de diseñar redes seguras y aplicar el principio de mínimo privilegio.
Sistemas Tolerantes a Fallos: Cómo asegurar que una aplicación siga funcionando aunque fallen algunos componentes.
Escalabilidad: Cómo hacer que la infraestructura se adapte sola a los cambios de tráfico.

---

Diagrama de la Arquitectura

Así es como se ve la arquitectura que despliega el código. El diagrama lo hice con draw.io.
El diagrama la encontraras en la carpeta de recursos.
![Diagrama de arquitectura](./Recursos/1st.drawio.pdf)
---

Tecnología / Servicio - Nube Amazon Web Services

Automatización - Terraform Me permite definir toda la infraestructura en archivos de texto. Es muy potente y fácil de leer aunque estoy aprendiendo.
Redes - AWS VPC y Subredes - Para crear una red privada y aislada en la nube, separando los recursos públicos de los privados, asi generando mas seguridad tambien
Balanceo de carga - Application Load Balancer - Es ideal para tráfico web y se integra perfectamente con el Auto Scaling.
Servidores - Ec2- Auto Scaling Group - Me permite tener la cantidad justa de servidores funcionando en todo momento, de forma automática.
Base de Datos - AWS RDS - sé RDS para no tener que preocuparme por administrar la base de datos (instalar, hacer backups, etc.)
Seguridad - Security Groups y Roles de IAM -  Los Security Groups actúan como un firewall para controlar el tráfico, y los roles de IAM son la forma correcta de dar permisos sin usar contraseñas.

---

¿Qué hace esta Infraestructura?

Es tolerante a fallos: La aplicación está repartida en dos Zonas de Disponibilidad distintas. Si una falla, la otra sigue funcionando sin problemas. El balanceador, los servidores y la base de datos están preparados para esto.

Escala sola: El número de servidores aumenta si hay mucho tráfico y disminuye si hay poco. Esto lo hace el Auto Scaling Group, que mira la carga de la CPU para decidir cuándo actuar. Así se ahorran costes.

Es segura: La base de datos y otros componentes críticos están en subredes privadas, sin acceso desde internet. Solo se permite el tráfico estrictamente necesario entre las distintas capas, gracias a los grupos de seguridad.

---

Estructura de los Archivos

El repositorio está organizado de la siguiente manera:

main.tf - Define todos los recursos de AWS que se van a crear.
variables.tf - Aquí defino las variables que uso en el proyecto (la región, IPs, etc.).
outputs.tf - Define qué información quiero obtener al final (como la URL del servidor).
terraform.tfvars.example - un archivo de ejemplo para que cualquiera pueda poner sus propias contraseñas de la DB
Recursos - Todos los archivos adjuntos externos
README.md - Este mismo archivo.

---


Próximos Pasos

Aunque el proyecto está completo, siempre se puede mejorar. Algunas ideas para el futuro:
Añadir monitorización con CloudWatch para crear alarmas y ver el rendimiento en tiempo real.
Usar contenedores con Docker y ECS para gestionar la aplicación de una forma más moderna.(Todavia no se docker asi que sera en un futuro proximo cercano!!)

---

Contacto

¡Gracias por tomarte el tiempo de ver mi proyecto! Si quieres hablar sobre él o cualquier otra cosa, aquí me puedes encontrar:

Autor: George Bogdan Dinu
LinkedIn: https://www.linkedin.com/in/georgebogdandinu