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
        match "images/**" $ do
            route   idRoute
            compile copyFileCompiler

        match "js/**" $ do
            route   idRoute
            compile copyFileCompiler

        match "font/**" $ do
            route   idRoute
            compile copyFileCompiler

        match "css/**" $ do
            route   idRoute
            compile compressCssCompiler

        match "pdfs/**" $ do
            route   idRoute
            compile copyFileCompiler

        match "favicon.ico" $ do
            route idRoute
            compile copyFileCompiler 

        match (fromList ["about.markdown", "contact.markdown", "flow.markdown"]) $ do
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

        match "fiction/**" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags ficTags)
                >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags ficTags)
                >>= relativizeUrls

        essTags <- buildTags "essays/*" (fromCapture "tags/*.html")

        tagsRules essTags $ \tag pattern -> do
            let title = "Essays tagged \"" ++ tag ++ "\""
            route idRoute
            compile $ do
                essays <- recentFirst =<< loadAll pattern
                let ctx = constField "title" title
                        `mappend` listField "essays" postCtx (return essays)
                        `mappend` defaultContext

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls

        match "essays/**" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags essTags)
                >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags essTags)
                >>= relativizeUrls

        clongTags <- buildTags "conlangs/*" (fromCapture "tags/*.html")

        tagsRules clongTags $ \tag pattern -> do
            let title = "Conlangs tagged \"" ++ tag ++ "\""
            route idRoute
            compile $ do
                conlangs <- recentFirst =<< loadAll pattern
                let ctx = constField "title" title
                        `mappend` listField "conlangs" postCtx (return conlangs)
                        `mappend` defaultContext

                makeItem ""
                    >>= loadAndApplyTemplate "templates/tag.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls

        match "conlangs/**" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags essTags)
                >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags essTags)
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