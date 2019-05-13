package de.halirutan.wlinfo

import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Test
import java.io.File
import kotlin.system.measureTimeMillis
import kotlin.test.assertTrue

/**
 * Created by patrick on 12.05.19. (c) Patrick Scheibe 2019
 *
 *
 */
internal class UtilsTest {

    private val wordsFile = "words.txt"
    private val symbolsFile = "symbolNames.txt"

    @Test
    fun testMatching() {
        val words = listOf("Beach", "Beadle", "Bean", "Beard", "Beardmore", "Beardsley", "Bearnaise", "Beasley", "Beatlemania", "Beatles", "Beatrice", "Beatrix", "Ceatriz", "Beau", "Beaufort")
        val regex = Regex(createReducedRegex(words))
        for (w in words) {
            assertTrue(regex.matches(w))
        }
        for (w in listOf("Baal", "Baals", "Babbage", "Babbitt", "Babel", "Babels", "Babylon", "Babylonia", "Babylonian", "Babylonians", "Babylons", "Bacall", "Bacardi", "Bacchanalia", "Bacchic")) {
            assertFalse(regex.matches(w))
        }
    }

    @Test
    fun testDollarMatching() {
        val words = listOf('$' + "Dollar", '$' + "Doll", "Dollar", "Doll")
        val regex = Regex(createReducedRegex(words))
        for (w in words) {
            assertTrue(regex.matches(w))
        }
    }

    @Test
    fun testPerformanceTrie() {
        val wordListURL = UtilsTest::class.java.getResource(wordsFile)
        val symbolListURL = UtilsTest::class.java.getResource(symbolsFile)
        val words = File(wordListURL.toURI()).readLines()
        val symbols = File(symbolListURL.toURI()).readLines()
// for the usage here, we need to un-escape on level in front of the dollar signs
        val regex = Regex(createReducedRegex(symbols).replace("\\\\$", "\\$"))
        var matches = true
        val time = measureTimeMillis {
            for (w in symbols) {
                matches = matches && regex.matches(w)
            }
            for (w in words) {
                regex.matches(w)
            }
        }
        println("Do all symbols match: $matches, required time: $time milliseconds")

    }

    @Test
    fun testPerformanceNormalRegex() {
        val wordListURL = UtilsTest::class.java.getResource(wordsFile)
        val symbolListURL = UtilsTest::class.java.getResource(symbolsFile)
        val words = File(wordListURL.toURI()).readLines()
        val symbols = File(symbolListURL.toURI()).readLines()

        val regex = Regex(symbols.joinToString("|", "(", ")") {
            it.replace("$", "\\$")
        })
        var matches = true
        val time = measureTimeMillis {
            for (w in symbols) {
                matches = matches && regex.matches(w)
            }
            for (w in words) {
                regex.matches(w)
            }
        }
        println("Do all symbols match: $matches, required time: $time milliseconds")

    }


}