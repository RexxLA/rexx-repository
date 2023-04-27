/* Rexx */
say 'café'
say length('café')
say reverse('café')
say substr('café', 3, 2)

-- broken because Rexx doesn't manage the surrogate pairs
say '𝖼𝖺𝖿é'
say length('𝖼𝖺𝖿é')
say reverse('𝖼𝖺𝖿é')
say substr('𝖼𝖺𝖿é', 3, 2)

-- broken because Rexx doesn't manage the grapheme clusters
say 'café'
say length('café')
say reverse('café')
say substr('café', 3, 2)
