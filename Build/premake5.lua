-- For reference, please refer to the premake wiki:
-- https://github.com/premake/premake-core/wiki

local ROOT = "../"

---------------------------------
-- [ WORKSPACE CONFIGURATION   --
---------------------------------
workspace "HelloWorld"                   -- Solution Name
  configurations { "Debug", "Release" }  -- Optimization/General config mode in VS
  platforms      { "x64", "x32" }        -- Dropdown platforms section in VS

  -- _ACTION is the argument you passed into premake5 when you ran it.
  local project_action = "UNDEFINED"
  if _ACTION ~= nill then project_action = _ACTION end


  -- Where the project files (vs project, solution, etc) go
  location( ROOT .. "project_" .. project_action)

  -------------------------------
  -- [ COMPILER/LINKER CONFIG] --
  -------------------------------
  flags "FatalWarnings" -- comment if you don't want warnings to count as errors
  warnings "Extra"

  -- see 'filter' in the wiki pages
  filter "configurations:Debug"    defines { "DEBUG" }  symbols  "On"
  filter "configurations:Release"  defines { "NDEBUG" } optimize "On"

  filter { "platforms:*32" } architecture "x86"
  filter { "platforms:*64" } architecture "x64"

  -- when building any visual studio project
  filter { "system:windows", "action:vs*"}
    flags         { "MultiProcessorCompile", "NoMinimalRebuild" }
    linkoptions   { "/ignore:4099" }      -- Ignore library pdb warnings when running in debug

  -- building makefiles
  filter { "action:gmake" }
    flags { "C++11" }

  -- building make files on mac specifically
  filter { "system:macosx", "action:gmake"}
    toolset "clang"

  filter {} -- clear filter when you know you no longer need it!


  -------------------------------
  -- [ PROJECT CONFIGURATION ] --
  ------------------------------- 
  project "HelloWorld"
    kind "ConsoleApp" -- "WindowApp" removes console
    language "C++"
    targetdir (ROOT .. "bin_%{cfg.buildcfg}_%{cfg.platform}") -- where the output binary goes.
    targetname "helloworld" -- the name of the executable saved to targetdir


    --------------------------------------
    -- [ PROJECT FILES CONFIGURATIONS ] --
    --------------------------------------
    local SourceDir = ROOT .. "Source/";
    -- what files the visual studio project/makefile/etc should know about
    files
    { 
      SourceDir .. "**.h", SourceDir .. "**.hpp", 
      SourceDir .. "**.c", SourceDir .. "**.cpp", SourceDir .. "**.tpp",
    }

    -- Exclude template files from project (so they don't accidentally get compiled)
    filter { "files:**.tpp" }
      flags {"ExcludeFromBuild"}

    filter {} -- clear filter!


    -- setting up visual studio filters (basically virtual folders).
    vpaths 
    {
      ["Header Files/*"] = { SourceDir .. "**.h", SourceDir .. "**.hxx", SourceDir .. "**.hpp" },
      ["Source Files/*"] = { SourceDir .. "**.c", SourceDir .. "**.cxx", SourceDir .. "**.cpp" },
    }


    -- where to find header files that you might be including, mainly for library headers.
    includedirs
    {
      SourceDir -- include root source directory to allow for absolute include paths
      -- include the headers of any libraries/dlls you need
    }


    -------------------------------------------
    -- [ PROJECT DEPENDENCY CONFIGURATIONS ] --
    -------------------------------------------
    libdirs
    {
      -- add dependency directories here
    }

    links
    {
      -- add depedencies (libraries) here
    }



