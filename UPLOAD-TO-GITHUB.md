# Add this starter package to `bhargavsrikar-5/v-comm`

**Important:** Do not upload this ZIP archive as a single file into GitHub. GitHub will store it as an archive; it will not unpack the project tree for you.

## Recommended method on Windows (GitHub Desktop)

1. Download and extract `v-comm-foundation-upload.zip` on your computer.
2. Open GitHub Desktop and sign in to the GitHub account that owns `bhargavsrikar-5/v-comm`.
3. Choose **File → Clone repository… → URL**.
4. Enter `https://github.com/bhargavsrikar-5/v-comm.git` and clone it to a local folder.
5. Open the extracted ZIP folder. Select **all its contents** (including `.gitignore` and `UPLOAD-TO-GITHUB.md`) and copy them.
6. Paste those contents into the cloned `v-comm` folder. Do not copy the outer ZIP or create an extra nested `v-comm-foundation` folder.
7. In GitHub Desktop, confirm the changed files are listed. Use commit message: `chore: add V-COMM repository foundation`.
8. Click **Commit to main**, then **Push origin**.

## Alternative: command line

After cloning the empty repository, copy the extracted package contents into the cloned repository directory, then run:

```bash
git add .
git commit -m "chore: add V-COMM repository foundation"
git push origin main
```

## What this package contains

This is a documentation and directory scaffold only. It does **not** contain runnable Flutter, Spring Boot, database, or admin-panel source code. See `README.md` and `docs/PROJECT_STATUS.md` for an honest list of what is completed and pending.
