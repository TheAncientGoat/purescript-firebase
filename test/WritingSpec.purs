module Test.WritingSpec (writingSpec) where

import Prelude (Unit, bind, ($))

import Control.Monad.Aff (Aff())
import Control.Monad.Eff.Class (liftEff)
import Data.Maybe (Maybe(Nothing))
import Data.Either (Either(Right))
import Web.Firebase as FB
import Web.Firebase.Monad.Aff (onceValue)
import Web.Firebase.UnsafeRef (refFor)
import Web.Firebase.DataSnapshot as D
import Web.Firebase.Types as FBT
import Test.Spec                  (describe, pending, it, Spec())
import Test.Spec.Runner           (Process())
import Test.Spec.Assertions       (shouldEqual, shouldNotEqual)
import PlayWithFire (Success(Success), snapshot2success)
import Data.Foreign as F

entriesRef :: forall eff. Aff (firebase :: FBT.FirebaseEff | eff) FBT.Firebase
entriesRef = refFor "https://purescript-spike.firebaseio.com/entries"

writingSpec ::  forall eff. Spec ( process :: Process, firebase :: FBT.FirebaseEff | eff) Unit
writingSpec = do
  describe "Writing" do
      it "can add an item to a list" do
        location <- entriesRef
        newChildRef <- liftEff $ FB.push (F.toForeign $ {success: "random numbered string"}) Nothing location
        snap <- onceValue newChildRef
        (D.key snap) `shouldNotEqual` Nothing
        -- key is different on every write. Checking unique keys is work for QuickCheck
        (snapshot2success snap) `shouldEqual` (Right (Success {success: "random numbered string"}))
        -- use key to read value

      it "can overwrite an existing item" do
        let secondValue = {success: "second value"}
        location <- entriesRef
        newChildRef <- liftEff $ FB.push (F.toForeign $ {success: "initial value"}) Nothing location
        _ <- liftEff $ FB.set (F.toForeign $ secondValue) Nothing newChildRef
        snap <- onceValue newChildRef
        (snapshot2success snap) `shouldEqual` (Right (Success secondValue))

      pending "can overwrite an existing item in Aff"
      pending "can add a server-side timestamp to new items"
      pending "push Aff when writing to non-existant location returns an error"
      -- implement AFF with error callback (it is error object or nothing, so we can make it 'or Right "write successful", which we can reuse in a value writeSuccess so we can assert against that. Not sure how to combine that with the value of the key that is also returned from the js function'