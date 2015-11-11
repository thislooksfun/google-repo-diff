module.exports =
  setInstance: (@gRepo) ->
  
  repositoryForPath: (path) ->
    console.log path
    repo = @gRepo?.host?.getRepoForPath?(path)
    console.log repo
    return repo