# PS_NameConversions
Module / Function collection for various name/path conversions

## Why

During my daily administrative work I regularly run into issues with Firstname Lastname sequences turned around, cmdlets using classic path syntax (like Get-Mailbox's OrganizationalUnit) instead of LDAP-Syntax (like Get-ADUser's DistinguishedName). I find it very time consuming to manually rewrite these strings to the other form, so I wrote a couple of conversion functions to do it for me.


## ConvertTo-DistinguishedName -CanonicalName [-UseCN]

Converts a classic path string (domain.tld/ou1/ou2/user) to ldap notation (CN=user,OU=ou2,OU=ou1,DC=domain,DC=tld). `-UseCN` triggers, if the last part of the path should be treated as OU or CN.


## ConvertTo-CanonicalName -DistinguishedName

Converts an ldap path string (CN=user,OU=ou2,OU=ou1,DC=domain,DC=tld) to a classic path (domain.tld/ou1/ou2/user).


## Switch-Name -Name

Takes any sequence of words and reversed their order. So, in case of a name, 'Albert Einstein' would be swapped to 'Einstein Albert'.
