-- For documentation on all premake functions please see the wiki:
--   https://github.com/premake/premake-core/wiki


---------------------------------
-- [ WORKSPACE CONFIGURATION   --
---------------------------------
-- Setting up the workspace. A workspace can have multiple Projects. 
-- In visual studio a workspace corresponds to a solution.
workspace "HelloWorld"
  -- LUA note: 'workspace' is a function, that we are calling with an argument of "Hello World".
  --            The parentheses () for functions are optional in lua, but only when there is no ambiguity.
  --            
  --            For example if using an operator to modify the argument, like:
  --                 workspace "HelloWorld" + 2
  --            That would be ambiguous and cause an error, because it can represent either:
  --                 workspace("HelloWorld") + 2
  --            or
  --                 workspace("HelloWorld" + 2)
  --                 
  --            Similarly since tables/lists/arrays are writen with curly braces {}, you can
  --            pass that in without () as well, like with the 'configurations' function below.


  -- LUA note: indentation and whitespace is not important in lua. They are used here only to improve readability.

  configurations { "Debug", "Release" } -- Optimization/General config mode in VS
  platforms { "x64", "x32" }            -- Dropdown platforms section in VS
  -- Premake Note: Platforms and configurations:
  --            We are declaring these names for the platform and configurations,
  --            but they don't actually have any meaning associated with them yet.
  --            
  --            The actual meaning is applied with filters, below in the compiler/linker section


  -- LUA NOTE: by default all variables are global unless using the local keyword.
  local project_action = "UNDEFINED"
  -- _ACTION is the argument passed into premake5 when you run it.
  if _ACTION ~= nill then
    project_action = _ACTION
  end
  -- LUA note: Quick example of if statement. 
  --            Since LUA does not require semicolons or care about whitespace, scopes are closed with 'end'
  --            when writing functions, if/while loops, etc.
  --            
  --            Also: ~ is negation LUA operator
  

  -- Where the project files (vs project, solution, etc) go
  location( "project_" .. project_action )
  -- LUA Note: string concatonation is performed with the concatonate .. operator. 
  --            So this:
  --               "Hello" .. "World"
  --            Results in:
  --               "HelloWorld"
  --               
  --            Notice how for the above 'location' function call we had to use parentheses, 
  --            since otherwise it would have been amgiguous.


  -------------------------------
  -- [ COMPILER/LINKER CONFIG] --
  -------------------------------
  flags "FatalWarnings" -- comment if you don't want warnings to count as errors
  warnings "Extra"

  -- Premake Note: Filters
  --            Filters allow you to run certain bits of code only when the filter's conditions are met
  --            it is important to note that the moment you open a filter, all following directives will 
  --            only occur when that filter is met.
  --            
  --            Therefore it is critically important to close filters when done using them!
  --            
  --            You close filters with:
  --              filter {}


  -- Here we are setting up what differentiates the configurations that we called "Debug" and "Release"
  filter "configurations:Debug"    defines { "DEBUG" }  symbols  "On"
  filter "configurations:Release"  defines { "NDEBUG" } optimize "On"
  -- Note that filters don't care about whitespace; They are just written on single lines here for readability

  -- Consider adding your own configurations. For example:
  -- 
  --      If you use unit testing you can set up a "Testing" configuration by adding "Testing" 
  --      to the list of configurations at the top of this file. It will then be selectable in visual studio.
  --      
  --      Then you can use a filter to apply directives only when that configuration is selected in visual studio
  --      
  --      As an example, we can define a TESTING macro, as well as include extra files and libs:
  --      
  --          filter "configurations:Testing"
  --             defines {"TESTING"}
  --             files { "PATH/TO/TESTING/SOURCE" }
  --             links { "TESTING.lib" }
  --             
  --          filter {} -- clear the filter when done adding to it!


  filter { "platforms:*32" } architecture "x86"
  filter { "platforms:*64" } architecture "x64"

  -- You can AND filters as follows:
  filter { "system:windows", "action:vs*"}
    flags         { "MultiProcessorCompile", "NoMinimalRebuild" }
    linkoptions   { "/ignore:4099" }      -- Ignore library pdb warnings when running in debug
  -- We can use wildcards (*) in filters. This makes them very powerful
  --    In this case, it allows us to support vs2012, vs2013 and vs2015 with one filter.

  -- To OR filters:
  --    filter {"system:linux or system:mac"}
  --       ...

  filter {}  -- clear filter when you know you no longer need it!

  --     if we had not cleared this filter, then the project directive below would be
  --     considered part of the filter.
  --     
  --     So the project would ONLY be defined if creating a visual studio project on windows!


  -------------------------------
  -- [ PROJECT CONFIGURATION ] --
  ------------------------------- 
  project "HelloWorld"
    kind "ConsoleApp" -- "WindowApp" removes console
    language "C++"
    targetdir "bin_%{cfg.buildcfg}_%{cfg.platform}" -- Where the output binary goes. This will be generated when we build from the makefile/visual studio project/etc.
    targetname "helloworld" -- the name of the executable saved to 'targetdir'
                            -- If left blank will default to the 'project' name

    --       The active configuration fills in for the %{cfg.buildcfg} token when used in a string
    --       The active platform fills in for the %{cfg.platform} token when used in a string
  

    --------------------------------------
    -- [ PROJECT FILES CONFIGURATIONS ] --
    --------------------------------------
    local SourceDir = "./Source/";
    -- what files the visual studio project/makefile/etc should know about
    files
    { 
      -- all paths in premake can have * for wildcard.
      --     /Some/Path/*.txt     will find any .txt file in /Some/Path
      --     /Some/Path/**.txt    will find any .txt file in /Some/Path and any of its subdirectories
      SourceDir .. "**.h", 
      SourceDir .. "**.hpp", 
      SourceDir .. "**.c",
      SourceDir .. "**.cpp",
      SourceDir .. "**.tpp"
    }

    -- Exclude template files from project (so they don't accidentally get compiled)
    filter { "files:**.tpp" }
      flags {"ExcludeFromBuild"}

    filter {} -- clear filter!


    -- setting up visual studio filters (basically virtual folders).
    vpaths 
    {
      ["Header Files/*"] = { 
        SourceDir .. "**.h", 
        SourceDir .. "**.hxx", 
        SourceDir .. "**.hpp",
      },
      ["Source Files/*"] = { 
        SourceDir .. "**.c", 
        SourceDir .. "**.cxx", 
        SourceDir .. "**.cpp",
      },
    }

    -- You can use filters on files as well. 
    -- Whatever follows will then only apply to files that match the filter.

    -- For template files that are included in headers, we want to make sure that they don't accidentally get compiled.
    filter { "files:**.tpp" }
      flags {"ExcludeFromBuild"}

    filter {} -- clear filter!



    -- where to find header files that you might be including, mainly for library headers.
    includedirs
    {
      SourceDir -- include root source directory to allow for absolute include paths
      -- include the headers of any libraries/dlls you need
    }


    -------------------------------------------
    -- [ PROJECT DEPENDENCY CONFIGURATIONS ] --
    -------------------------------------------

    -- basically a set of paths/rules for where to find libs/dlls/etc
    libdirs
    {
      -- provide a path(s) for your libraries that are required when compiling.
      -- fmod, etc.
      -- example: 
      --     "./Source/Dependencies/fmod_version/lib"
      -- or to be more generic:
      --     "./Source/Dependencies/**/lib" which could be constructed from strings, like: 
      --     SourceDir .. "Dependencies/**/lib"
      --     
      -- NOTE: If you want to include debug/release specific libraries use tokens:
      --     %{cfg.buildcfg} evaluates to "Debug", "Release", etc.
      --     
      --     So if you structure your libraries to have a folder with "Debug" or "Release" 
      --     that contain the appropriate lib/dll/whatever then you can just do something like:
      --         SourceDir.."Dependencies/**/lib_%{cfg.buildcfg}" 
      --     Which will for example evaluate for:
      --          "/Source/Dependencies/fmod_01/lib_x32"
      --     Which you would put the 32 bit version of fmod's lib into.
    }

    links
    {
      -- A list of the actual library/dll names to include
      -- For example if you want to include fmod_123.lib you put "fmod_123" here. Just like when adding to visual studio's linker.
    }

    -- Premake Note: for any of these you can call them inside of filters, for example:
    --        filter { "configurations:Debug" }
    --           links { "fmod_debug"}
    --         filter { "configurations:Release" }
    --           links { "fmod_release"}
    --           
    -- This goes for files, libdirs, really any directives.



-- PREMAKE NOTE: make files
--        When you run premake5 with the 'gmake' argument you will create several make files:
--        
--           - one core make file named the default 'makefile' for the workspace
--           - one make file for each project, named '<projectname>.make'
--           
--        When running 'make', the default makefile is used and will pass arguments to the 
--        make file of whichever project you select.
--        
--        If you run this command:
--           make help
--             
--        You are selecting the 'help' rule in the make file, and will show you all of
--        the configurations you can build
--        
--        For example, to compile in Release for 64 bit you would run:
--           make config=release_x64
--          
--        If you had multiple projects, you could pass the project name in as the target.
--           make config=<CONFIG> <RELEASE>
--           
--        Lastly, a useful tip for debugging makefiles is to set the verbose variable:
--           make verbose=1
-- 
-- 
