# Github Pages Workspace Template

This is a template for a github pages site.  

To use:

1. Add additional dependencies in your Gem file (probably not needed.)
2. Open the workspace in VS Code.
   - This will load the docker image for developing the website, along with installing all required dependencies.
3. Run bundle update to create the Gemfile.lock file
   - This will update all of the dependencies in your gemfile, and "lock" them into the configuration.  This is needed in order to reproduce your exact build, with specific dependency versions. You can run update at any time, but you should make sure your website still builds after you do.  If you find that a specific version doesn't work, you can limit the version of the dependency in the Gemfile.
   - It used to be recommended to _not_ commit your Gemfile.lock (or did I make that up?) But now it is.
4. Build and serve the site

    ```bash
    bundle exec jekyll serve
    ```

5. Test the site.  After you build it, you can run some very _simple_ tests using [html-proofer](https://github.com/gjtorikian/html-proofer).  This has been very useful for me to check that all of my links work appropriately.

    ```bash
    bundle exec htmlproofer ./_site
    ```

6. This template also includes a github action to test the site on every push.  This action
   1. Builds the site
   2. Runs htmlproofer