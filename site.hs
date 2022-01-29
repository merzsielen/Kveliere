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

        match (fromList ["about.markdown", "contact.markdown", "the-little-brown-book.markdown"]) $ do
            route   $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls
        
        ficTags <- buildTags "fiction/*" (fromCapture "tags/*.html")

        tagsRules ficTags $ \tag pattern -> do
            let title = "Fiction tagged \"" ++ tag ++ "\""
            route idRoute
            compile $ do
                fiction <- recentFirst =<< loadAll pattern
                let ctx = constField "title" title
                        `mappend` listField "fiction" postCtx (return fiction)
                        `mappend` defaultContext

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls

        match "fiction/*" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/fiction.html"    (postCtxWithTags ficTags)
                >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags ficTags)
                >>= relativizeUrls

        match "index.html" $ do
            route idRoute
            compile $ do
                -- posts <- recentFirst =<< loadAll "posts/*"
                let indexCtx =
                        -- listField "posts" postCtx (return posts) `mappend`
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

postCtxWithTags :: Tags -> Context String
postCtxWithTags tags = tagsField "tags" tags `mappend` postCtx

-- cleanRoute :: Routes 
-- cleanRoute = customRoute createIndexRoute
--     where
--         createIndexRoute ident = takeDirectory p
--                                     </> takeBaseName p
--                                     </> "index.html"
--                                 where p = toFilePath ident

-- cleanIndexUrls :: Item String -> Compiler (Item String)
-- cleanIndexUrls = return . fmap (withUrls clean)
--     where
--         idx = "index.html"
--         clean url
--             | idx `isSuffixOf` url = take (length url - length idx) url
--             | otherwise            = url