import sys

with open('lib/screens/user/user_screens.dart', 'r') as f:
    content = f.read()

with open('old_vip.txt', 'r') as f:
    old_vip = f.read()

with open('new_vip.txt', 'r') as f:
    new_vip = f.read()

if old_vip in content:
    new_content = content.replace(old_vip, new_vip)
    with open('lib/screens/user/user_screens.dart', 'w') as f:
        f.write(new_content)
    print("Replaced successfully")
else:
    print("Old VIP text not found in user_screens.dart")
