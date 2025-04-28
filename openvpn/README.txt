1) run: ansible-galaxy install community.general
2) run: ansible-playbook -i hosts.yaml openvpn-playbook.yml
3) you now have a tunnel opener file in this dir called 'amit.ovpn',
    run: sudo openvpn --config amit.ovpn
    a tunnel is now created

If you want to run the tunnel on detached mode (so it will not occupy your terminal)
run: sudo openvpn --config amit.ovpn --daemon