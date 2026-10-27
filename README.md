# ctf-practice-kit

Small helpers for CTF and lab practice.

## flaghunt

You have a shell on a box. Where are the flags? `flaghunt` checks the usual
places and reports which flag files are readable and which exist but need
privilege escalation.

| Script | Target |
|---|---|
| `flaghunt.sh` | Linux |
| `flaghunt.ps1` | Windows |

### What it does

- Looks for common flag filenames: `user.txt`, `root.txt`, `proof.txt`, `local.txt`, `flag*.txt`, `*.flag`
- Reports each as **readable** or **exists, not readable** (a hint that privesc is the next step)
- Checks common hiding spots: home directories, web roots, `/opt`, `/tmp`, Administrator's Desktop, `C:\inetpub`
- Optional content search for flag formats: `HTB{}`, `THM{}`, `flag{}`, `CTF{}`, `picoCTF{}`
- Read-only: it lists and prints, and never modifies anything

### Usage

```bash
# Linux
chmod +x flaghunt.sh
./flaghunt.sh              # filename search from /
./flaghunt.sh -d /home -p  # limit to /home, print readable flag contents
./flaghunt.sh -c           # also grep contents for flag formats
```

```powershell
# Windows
powershell -ep bypass -File .\flaghunt.ps1
.\flaghunt.ps1 -Path C:\Users -Print
.\flaghunt.ps1 -Content
```

## Responsible use

Use only on CTF challenges, practice labs (Hack The Box, TryHackMe, your own VMs),
or systems you have written authorization to test.
