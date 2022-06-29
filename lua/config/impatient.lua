local status, impatient = pcall(require, "impatient")
if not status then
  print("impatient not found")
  return
end

_G.__luacache_config = {
  chunks = {
    enable = true,
    path = vim.fn.stdpath("cache") .. "/luacache_chunks",
  },
  modpaths = {
    enable = true,
    path = vim.fn.stdpath("cache") .. "/luacache_modpaths",
  },
}

impatient.enable_profile()
