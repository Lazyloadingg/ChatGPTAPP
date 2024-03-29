//
// Created by 陈秋文 on 2022/9/13.
//

/*
 * Tencent is pleased to support the open source community by making
 * WCDB available.
 *
 * Copyright (C) 2017 THL A29 Limited, a Tencent company.
 * All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use
 * this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 *       https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import WCDB_Private

public protocol TransactionInterface {
    /// Separate interface of `run(transaction:)`
    /// You should call `begin`, `commit`, `rollback` and all other operations in same thread.
    /// - Throws: `Error`
    func begin() throws

    /// Separate interface of `run(transaction:)`
    /// You should call `begin`, `commit`, `rollback` and all other operations in same thread.
    /// - Throws: `Error`
    func commit() throws

    /// Separate interface of run(transaction:)
    /// You should call `begin`, `commit`, `rollback` and all other operations in same thread.
    /// Throws: `Error`
    func rollback() throws

    /// Check whether the current database has begun a transaction in the current thread.
    var isInTransaction: Bool { get }

    /// Separate interface of `run(nestedTransaction:)`
    /// You should call `beginNestedTransaction`, `commitNestedTransaction`, `rollbackNestedTransaction` and all other operations in same thread.
    /// - Throws: `Error`
    func beginNestedTransaction() throws

    /// Separate interface of `run(nestedTransaction:)`
    /// You should call `beginNestedTransaction`, `commitNestedTransaction`, `rollbackNestedTransaction` and all other operations in same thread.
    /// - Throws: `Error`
    func commitNestedTransaction() throws

    /// Separate interface of `run(nestedTransaction:)`
    /// You should call `beginNestedTransaction`, `commitNestedTransaction`, `rollbackNestedTransaction` and all other operations in same thread.
    /// Throws: `Error`
    func rollbackNestedTransaction() throws

    /// Run a  transaction in closure
    ///
    ///     try database.run(transaction: { _ in
    ///         try database.insert(objects, intoTable: table)
    ///     })
    ///
    /// - Parameter transaction: Operation inside transaction
    /// - Throws: `Error`
    typealias TransactionClosure = (Handle) throws -> Void
    func run(transaction: @escaping TransactionClosure) throws

    /// Run a controllable transaction in closure
    ///
    ///     try database.run(controllableTransaction: { _ in
    ///         try database.insert(objects, intoTable: table)
    ///         return true // return true to commit transaction and return false to rollback transaction.
    ///     })
    ///
    /// - Parameter controllableTransaction: Operation inside transaction
    /// - Throws: `Error`
    typealias ControlableTransactionClosure = (Handle) throws -> Bool
    func run(controllableTransaction: @escaping ControlableTransactionClosure) throws

    /// Run a  nested transaction in closure
    ///
    ///     try database.run(nestedTransaction: { () throws -> Bool in
    ///         try database.insert(objects, intoTable: table)
    ///     })
    ///
    /// - Parameter transaction: Operation inside transaction
    /// - Throws: `Error`
    func run(nestedTransaction: @escaping TransactionClosure) throws

    typealias PauseableTransactionClosure = (Handle, inout Bool, Bool) throws -> Void
    /// Run a pauseable transaction in block.
    ///
    /// Firstly, WCDB will begin a transaction and call the block.
    /// After the block is finished, WCDB will check whether the main thread is suspended due to the current transaction.
    /// If not, it will call the block again; if it is, it will temporarily commit the current transaction.
    /// Once database operations in main thread are finished, WCDB will rebegin a new transaction in the current thread and call the block.
    /// This process will be repeated until the second parameter of the block is specified as true, or some error occurs during the transaction.
    ///
    ///     try self.database.run(pauseableTransaction: { (handle, stop, isNewTransaction) in
    ///         if (isNewTraction) {
    ///             // Do some initialization for new transaction.
    ///         }
    ///
    ///         // Perform a small amount of data processing.
    ///
    ///         if( All database operations are finished ) {
    ///             stop = true;
    ///         }
    ///     }
    ///
    /// - Parameter pauseableTransaction: Operation inside transaction for one loop.
    /// - Throws: `Error`
    func run(pauseableTransaction: @escaping PauseableTransactionClosure) throws
}

extension TransactionInterface where Self: HandleRepresentable {
    public func begin() throws {
        let handle = try getHandle()
        if !WCDBHandleBeginTransaction(handle.cppHandle) {
            throw handle.getError()
        }
    }

    public func commit() throws {
        let handle = try getHandle()
        if !WCDBHandleCommitTransaction(handle.cppHandle) {
            throw handle.getError()
        }
    }

    public func rollback() throws {
        let handle = try getHandle()
        WCDBHandleRollbackTransaction(handle.cppHandle)
    }

    public var isInTransaction: Bool {
        guard let handle = try? getHandle() else {
            return false
        }
        return WCDBHandleIsInTransaction(handle.cppHandle)
    }

    public func beginNestedTransaction() throws {
        let handle = try getHandle()
        if !WCDBHandleBeginNestedTransaction(handle.cppHandle) {
            throw handle.getError()
        }
    }

    public func commitNestedTransaction() throws {
        let handle = try getHandle()
        if !WCDBHandleCommitNestedTransaction(handle.cppHandle) {
            throw handle.getError()
        }
    }

    public func rollbackNestedTransaction() throws {
        let handle = try getHandle()
        WCDBHandleRollbackNestedTransaction(handle.cppHandle)
    }

    public func run(transaction: @escaping TransactionClosure) throws {
        let handle = try getHandle()
        if handle.isInTransaction {
            try transaction(handle)
            return
        }
        let transactionBlock: @convention(block) (CPPHandle) -> Bool = {
            cppHandle in
            let handle = Handle(withCPPHandle: cppHandle)
            var ret = true
            do {
                try transaction(handle)
            } catch {
                ret = false
            }
            return ret
        }
        let transactionBlockImp = imp_implementationWithBlock(transactionBlock)
        if !WCDBHandleRunTransaction(handle.cppHandle, transactionBlockImp) {
            throw handle.getError()
        }
    }

    public func run(controllableTransaction: @escaping ControlableTransactionClosure) throws {
        var transactionRet = true
        let transactionBlock: @convention(block) (CPPHandle) -> Bool = {
            cppHandle in
            let handle = Handle(withCPPHandle: cppHandle)
            var ret = true
            do {
                transactionRet = try controllableTransaction(handle)
            } catch {
                ret = false
            }
            return ret && transactionRet
        }
        let transactionBlockImp = imp_implementationWithBlock(transactionBlock)
        let handle = try getHandle()
        if !WCDBHandleRunTransaction(handle.cppHandle, transactionBlockImp) && transactionRet {
            throw handle.getError()
        }
    }

    public func run(nestedTransaction: @escaping TransactionClosure) throws {
        let transactionBlock: @convention(block) (CPPHandle) -> Bool = {
            cppHandle in
            let handle = Handle(withCPPHandle: cppHandle)
            var ret = true
            do {
                try nestedTransaction(handle)
            } catch {
                ret = false
            }
            return ret
        }
        let transactionBlockImp = imp_implementationWithBlock(transactionBlock)
        let handle = try getHandle()
        if !WCDBHandleRunNestedTransaction(handle.cppHandle, transactionBlockImp) {
            throw handle.getError()
        }
    }

    public func run(pauseableTransaction: @escaping PauseableTransactionClosure) throws {
        let handle = try getHandle()
        let transactionBlock: @convention(block) (CPPHandle, UnsafeMutablePointer<Bool>, Bool) -> Bool = {
            _, cStop, isNewTransaction in
            var ret = true
            var stop = false
            do {
                try pauseableTransaction(handle, &stop, isNewTransaction)
                cStop.pointee = stop
            } catch {
                ret = false
            }
            return ret
        }
        let transactionBlockImp = imp_implementationWithBlock(transactionBlock)
        if !WCDBHandleRunPauseableTransaction(handle.cppHandle, transactionBlockImp) {
            throw handle.getError()
        }
    }
}
