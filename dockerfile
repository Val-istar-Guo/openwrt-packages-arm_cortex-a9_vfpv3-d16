FROM valistarguo/openwrt-sdk-arm_cortex-a9_vfpv3-d16 as builder

WORKDIR /root/sdk
COPY .config /root/sdk/.config
RUN cd /root/sdk && \
    git clone https://github.com/Hill-98/luci-app-shadowsocksr.git package/luci-app-shadowsocksr && \
    git clone https://github.com/Hill-98/openwrt-ckipver.git package/ckipver && \
    git clone https://github.com/Hill-98/openwrt-cdns package/cdns && \
    git clone https://github.com/Hill-98/openwrt-shadowsocksr package/shadowsocksr-libev && \
    git clone https://github.com/sensec/ddns-scripts_aliyun.git package/ddns-scripts_aliyun && \
    git clone https://github.com/aa65535/openwrt-dns-forwarder.git package/dns-forwarder && \
    git clone https://github.com/Hill-98/openwrt-pdnsd package/pdnsd && \
    cd package/luci-app-shadowsocksr/tools/po2lmo && \
    make && make install && \
    cd /root/sdk

RUN make package/shadowsocksr-libev/compile package/ddns-scripts_aliyun/compile package/luci-app-shadowsocksr/compile package/ckipver/compile package/cdns/compile package/dns-forwarder/compile package/pdnsd/compile -j$((`nproc`+1)) V=s && \
    make package/index V=s && \
    ./staging_dir/host/bin/usign -G -s mime.key -p mime.pub && \
    ./staging_dir/host/bin/usign -S -m bin/packages/arm_cortex-a9_vfpv3-d16/base/Packages -s mime.key -x bin/packages/arm_cortex-a9_vfpv3-d16/base/Packages.sig && \
    mv mime.pub bin/packages/arm_cortex-a9_vfpv3-d16/base/mime.pub


FROM nginx
RUN mkdir /usr/share/nginx/packages
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /root/sdk/bin/packages/arm_cortex-a9_vfpv3-d16/base/ /usr/share/nginx/packages
RUN chown -R nginx /usr/share/nginx/packages && chgrp -R nginx /usr/share/nginx/packages
