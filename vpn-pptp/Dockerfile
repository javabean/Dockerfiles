FROM cedrik/baseimage:latest
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="Cédrik LIME"

#RUN ln -sf /bin/sv /etc/init.d/pptp
COPY runit_pptp /etc/service/pptp/run
#COPY runit_pptp /etc/my_init.d/pptp

ARG DNS_SERVER_1=8.8.8.8
ARG DNS_SERVER_2=8.8.4.4

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	pptpd iptables kmod \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& sed --regexp-extended -i'.bak' \
		-e "s/(#ms-dns 10.0.0.2)/\1\nms-dns ${DNS_SERVER_1}\nms-dns ${DNS_SERVER_2}\n/" \
		-e 's/(#connections 100)/\1\nconnections 10/' \
		/etc/ppp/pptpd-options \
	&& echo '\n\n\nnoipx\nmtu 1460\nmru 1460\n' >> /etc/ppp/pptpd-options \
	&& echo '\n\nlocalip 10.8.0.1\nremoteip 10.8.0.10-250\n'  >> /etc/pptpd.conf

#VOLUME ["/var/log"]

EXPOSE 1723

#ENTRYPOINT ["/entrypoint.sh"]
#CMD ["pptpd", "--fg"]
CMD ["/sbin/my_init"]
