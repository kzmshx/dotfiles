hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall:andUse("ForceTouchMapper", {
  config = {
    apps = {
      ["com.microsoft.VSCode"] = { keyStroke = { { "" }, 'f12' } },
      ["com.todesktop.230313mzl4w4u92"] = { keyStroke = { { "" }, 'f12' } }
    }
  },
  start = true
})
