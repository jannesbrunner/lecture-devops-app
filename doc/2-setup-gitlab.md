
# Setup GitLab

GitLab is in use for the CI/CD workflow. This project is adapted for GitLab CI/CD. <br/>
The [.gitlab-ci.yml](../.gitlab-ci.yml) will only work in a GitLab environment.
## 1 Create necessary branches

This project is using two branches that represent the staging and production environment:

- master 
  - Branch for staging environment
- production
  - Branch for production environment 

You can create these branches with git and push these branches to the repository.
You can also create these branches via GitLab repository webpage. <br/>

*Hint*: If you just forked or copied the entire project, you can skip creating branches for sure :)

## 2 Protect environment branches

It's best practice to protect the environment branches (master & production)!
In GitLab you can achieve this under `Settings/Repository/Protected branches`.



## 3 Setup GitLab (CI/CD)


  