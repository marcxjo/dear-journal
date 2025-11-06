# dear-journal - an encrypted, extensible journaling experience powered by Unix `password-store`

## About

`dear-journal` is a shell script that enables keeping one or multiple journals with GPG-encrypted notes. It uses the Unix password store (i.e., the script famously known as [`pass`](https://www.passwordstore.org/)) as its backend, and as such it re-uses much of `pass`'s most powerful functionality, such as its convenient Git repository configuration and syncing capabilities. `dear-journal` also provides an extension API, (vaguely) inspired by `pass`'s extension concept, that enables extending and customizing the journaling experience.
