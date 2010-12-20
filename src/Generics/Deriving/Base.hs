{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE CPP #-}

module Generics.Deriving.Base (
#ifndef __UHC__
  -- * Generic representation types
    V1, U1(..), Par1(..), Rec1(..), K1(..), M1(..)
  , (:+:)(..), (:*:)(..), (:.:)(..)

  -- ** Synonyms for convenience
  , Rec0, Par0, R, P
  , D1, C1, S1, D, C, S

  -- * Meta-information
  , Datatype(..), Constructor(..), Selector(..), NoSelector
  , Fixity(..), Associativity(..), Arity(..), prec

  -- * Representable type classes
  , Representable0(..), Representable1(..)

  ,
#else
  module UHC.Generics,
#endif

  ) where


#ifdef __UHC__
import UHC.Generics
#endif

#ifndef __UHC__
--------------------------------------------------------------------------------
-- Representation types
--------------------------------------------------------------------------------

-- | Void: used for datatypes without constructors
#ifdef __UHC__
V1 :: * -> *
#endif
data V1 p

-- | Unit: used for constructors without arguments
#ifdef __UHC__
U1 :: * -> *
#endif
data U1 p = U1

-- | Used for marking occurrences of the parameter
#ifdef __UHC__
Par1 :: * -> *
#endif
newtype Par1 p = Par1 { unPar1 :: p }


-- | Recursive calls of kind * -> *
#ifdef __UHC__
Rec1 :: (* -> *) -> * -> *
#endif
newtype Rec1 f p = Rec1 { unRec1 :: f p }

-- | Constants, additional parameters and recursion of kind *
#ifdef __UHC__
K1 :: * -> * -> * -> *
#endif
newtype K1 i c p = K1 { unK1 :: c }

-- | Meta-information (constructor names, etc.)
#ifdef __UHC__
M1 :: * -> * -> (* -> *) -> * -> *
#endif
newtype M1 i c f p = M1 { unM1 :: f p }

-- | Sums: encode choice between constructors
infixr 5 :+:
#ifdef __UHC__
(:+:) :: (* -> *) -> (* -> *) -> * -> *
#endif
data (:+:) f g p = L1 { unL1 :: f p } | R1 { unR1 :: g p }

-- | Products: encode multiple arguments to constructors
infixr 6 :*:
#ifdef __UHC__
(:*:) :: (* -> *) -> (* -> *) -> * -> *
#endif
data (:*:) f g p = f p :*: g p

-- | Composition of functors
infixr 7 :.:
#ifdef __UHC__
(:.:) :: (* -> *) -> (* -> *) -> * -> *
#endif
newtype (:.:) f g p = Comp1 { unComp1 :: f (g p) }

-- | Tag for K1: recursion (of kind *)
data R
-- | Tag for K1: parameters (other than the last)
data P

-- | Type synonym for encoding recursion (of kind *)
type Rec0  = K1 R
-- | Type synonym for encoding parameters (other than the last)
type Par0  = K1 P

-- | Tag for M1: datatype
data D
-- | Tag for M1: constructor
data C
-- | Tag for M1: record selector
data S

-- | Type synonym for encoding meta-information for datatypes
type D1 = M1 D

-- | Type synonym for encoding meta-information for constructors
type C1 = M1 C

-- | Type synonym for encoding meta-information for record selectors
type S1 = M1 S

-- | Class for datatypes that represent datatypes
class Datatype d where
  -- | The name of the datatype, fully qualified
#ifdef __UHC__
  datatypeName :: t d f a -> String
  moduleName   :: t d f a -> String
#else
  datatypeName :: t d (f :: * -> *) a -> String
  moduleName   :: t d (f :: * -> *) a -> String
#endif

-- | Class for datatypes that represent records
class Selector s where
  -- | The name of the selector
#ifdef __UHC__
  selName :: t s f a -> String
#else
  selName :: t s (f :: * -> *) a -> String
#endif

-- | Used for constructor fields without a name
data NoSelector

instance Selector NoSelector where selName _ = ""

-- | Class for datatypes that represent data constructors
class Constructor c where
  -- | The name of the constructor
#ifdef __UHC__
  conName :: t c f a -> String
#else
  conName :: t c (f :: * -> *) a -> String
#endif

  -- | The fixity of the constructor
#ifdef __UHC__
  conFixity :: t c f a -> Fixity
#else
  conFixity :: t c (f :: * -> *) a -> Fixity
#endif  
  conFixity = const Prefix

  -- | Marks if this constructor is a record
#ifdef __UHC__
  conIsRecord :: t c f a -> Bool
#else
  conIsRecord :: t c (f :: * -> *) a -> Bool
#endif
  conIsRecord = const False

  -- | Marks if this constructor is a tuple, 
  -- returning arity >=0 if so, <0 if not
#ifdef __UHC__
  conIsTuple :: t c f a -> Arity
#else
  conIsTuple :: t c (f :: * -> *) a -> Arity
#endif
  conIsTuple = const NoArity


-- | Datatype to represent the arity of a tuple.
data Arity = NoArity | Arity Int
  deriving (Eq, Show, Ord, Read)

-- | Datatype to represent the fixity of a constructor. An infix
-- | declaration directly corresponds to an application of 'Infix'.
data Fixity = Prefix | Infix Associativity Int
  deriving (Eq, Show, Ord, Read)

-- | Get the precedence of a fixity value.
prec :: Fixity -> Int
prec Prefix      = 10
prec (Infix _ n) = n

-- | Datatype to represent the associativy of a constructor
data Associativity =  LeftAssociative 
                   |  RightAssociative
                   |  NotAssociative
  deriving (Eq, Show, Ord, Read)

-- | Representable types of kind *
class Representable0 a rep where
  -- | Convert from the datatype to its representation
  from0  :: a -> rep x
  -- | Convert from the representation to the datatype
  to0    :: rep x -> a

-- | Representable types of kind * -> *
class Representable1 f rep where
  -- | Convert from the datatype to its representation
  from1  :: f a -> rep a
  -- | Convert from the representation to the datatype
  to1    :: rep a -> f a

#endif
