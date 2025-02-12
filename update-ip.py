import requests

def get_public_ip():
    response = requests.get('https://api.ipify.org?format=json')
    return response.json()['ip']

def update_tfvars_file(ip):
    with open('admin-ip.auto.tfvars', 'r') as file:
        lines = file.readlines()

    with open('admin-ip.auto.tfvars', 'w') as file:
        for line in lines:
            if 'admin_ips' in line:
                # Ajoutez votre IP à la liste existante
                line = f'admin_ips = ["{ip}/32", "IP_ADMIN_2/32", "IP_ADMIN_3/32"]\n'
            file.write(line)

if __name__ == "__main__":
    public_ip = get_public_ip()
    update_tfvars_file(public_ip)
