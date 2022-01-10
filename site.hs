--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import qualified GHC.IO.Encoding as E
import           Data.List              (sortBy,isSuffixOf)
import           System.FilePath.Posix  (takeBaseName,takeDirectory,(</>))


--------------------------------------------------------------------------------


main :: IO ()
main = do
    E.setLocaleEncoding E.utf8

    hakyll $ do
        match "images/*" $ do
            route   idRoute
            compile copyFileCompiler

        match "js/*" $ do
            route   idRoute
            compile copyFileCompiler

        match "font/roboto-mono/*" $ do
            route   idRoute
            compile copyFileCompiler

        match "font/tinos/*" $ do
            route   idRoute
            compile copyFileCompiler

        match "css/*" $ do
            route   idRoute
            compile compressCssCompiler

        match "favicon.ico" $ do
            route idRoute
            compile copyFileCompiler 

        match (fromList ["about.markdown", "contact.markdown"]) $ do
            route   $ cleanRoute
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

        match "posts/*" $ do
            route $ cleanRoute
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    postCtx
                >>= loadAndApplyTemplate "templates/default.html" postCtx
                >>= relativizeUrls

        create ["archive.html"] $ do
            route cleanRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let archiveCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        constField "title" "Archives"            `mappend`
                        defaultContext

                makeItem ""
                    >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                    >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                    >>= relativizeUrls


        match "index.html" $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let indexCtx =
                        listField "posts" postCtx (return posts) `mappend`
                        defaultContext

                getResourceBody
                    >>= applyAsTemplate indexCtx
                    >>= loadAndApplyTemplate "templates/default.html" indexCtx
                    >>= relativizeUrls

        match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    defaultContext

cleanRoute :: Routes 
cleanRoute = customRoute createIndexRoute
    where
        createIndexRoute ident = takeDirectory p
                                    </> takeBaseName p
                                    </> "index.html"
                                where p = toFilePath ident

cleanIndexUrls :: Item String -> Compiler (Item String)
cleanIndexUrls = return . fmap (withUrls clean)
    where
        idx = "index.html"
        clean url
            | idx `isSuffixOf` url = take (length url - length idx) url
            | otherwise            = url