# facebook2wordpress
Ruby program that exports posts on Facebook Page to a WP importable XML

## Tutorial 

### Step 1
Open `get_post_pics.rb` with your favorite text editor.
Edit line 9: Change `fasle` to `true` if you want to download all the photos posted on Facebook. Disable this feature would save time and bandwidth when just debugging.
Edit line 17: Page ID is a uniqe number which only the page's admins know. Usually it can be found on about page.
Edit line 18: `default_creator` is the author name that will be shown on WP posts. 

### Step 2
Get your `access_token` from Facebook API explorer (https://developers.facebook.com/tools/explorer/). Please note the token expires in 30 minutes.
Replace the example token with your real token by editing the file named `token`.

### Step 3
Now you are all set. Run

```
ruby get_post_pics.rb < token
```

on terminal and see if it works. If everything works correctly, it will get the lastest post on your page and export it XML files named after author names.

If the test aobve was successful, run
```
ruby get_post_pics.rb 999 < token
```
to get ALL of your posts. Change the number 999 if you have even more posts than that!

### Step 4
Enter your WP site's control panel. Install WP import tool if it hasn't been there. Import XML files. 
