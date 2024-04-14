---
author: Marek Semjan
date: "2023-02-26T17:03:52+02:00"
draft: true
summary: Can you link notes written in Markdown and Vimwiki syntax? If yes, how? This
  was a question that is answered in this post.
tags:
- Note
- Markdown
- Vimwiki
- ChatGPT
title: Linking Vimwiki And Markdown Notes
---
# Linking Vimwiki And Markdown Notes

Can I successfully link a Markdown note to a Vim Wiki one, and vice-versa?

## Troubles And Attempts To Solve Them

### file: and local:

I can go to a Vimwiki note from the Markdown ones, but when I try to go in the other direction, Vim Wiki just appends `.wiki` to my Markdown note file name.

One possible solution is to add `file:` or `local:`, which allows user to open any file type like this
```wiki
[[file:note.md|Note]]   - links become absolute paths, when converted to HTML
[[local:note.md|Note]]  - links become relative paths, when converted to HTML
```

But this opens a new Vim, or some other program that can open the MIME type of the given file.

### The Vim Way

Other "hack" is to type `gf` on your keyboard, while having cursor over the file path, which let's you successfully open the Markdown note, but you have to have your cursor over the path and other parts of the link won't work. This is a built-in way of opening files from Vim, and it is not limited just to Vim Wiki.

## Solution

These solutions were not good, so I've decided to google for a better one. It turns out that more people want to  link plain text files in different formats to their Vim Wiki notes. This was possible in older versions, but when Vim Wiki authors decided to fix a bug with links that contain a dot (`.`), it got "broken".

As of 26 March possible solutions are being [discussed](https://github.com/vimwiki/vimwiki/issues/1271
), but I am impatient, so I've decided to modify the Vim Wiki link handler, like someone suggested in the linked Github issue.. I don't know Vim Script, so I had to ask ChatGPT to help me, and then modified it's output.

You can add the following snippet to your `.vimrc` file:
```vim
" Override default vimwiki link handling
function! VimwikiLinkHandler(link)
  let current_file_base_path = expand('%:h')
  if match(a:link, '\.\(md\|wiki\)$') != -1
    try
      execute ':edit ' . current_file_base_path . '/' . a:link
      return 1
    catch
      echo "Failed opening file in vim."
    endtry
  endif
  return 0
endfunction
```

This will open the links that have `.md` and `.wiki` in their names. If you want other formats to be supported, modify the regex to include other extensions. E.g. for Python source files, you can change the appropriate line:
```vim
  if match(a:link, '\.\(md\|wiki\|py\)$') != -1
```

## Conclusion

In the current version of Vim Wiki, you can not link Markdown files in your notes written with the default Vim Wiki syntax (provided, you use Vim wiki syntax), because Vim Wiki automatically appends `.wiki` to the file name. In this article I've described what I've tried to fix it, and a possible work around that fixes the issue.
